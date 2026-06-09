import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/zone_repository.dart';
import 'map_grid_event.dart';
import 'map_grid_state.dart';
import '../../data/models/zone_model.dart';
import '../../data/models/zone_heatmap_model.dart';
import '../../data/models/top_demand_zone_model.dart';
import '../../data/models/zone_insights_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/zone_comparison_model.dart';
import '../../data/datasources/zone_boundary_service.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

/// Data class to pass to the isolate (compute requires a single argument)
class _GeoJsonParams {
  final List<Map<String, dynamic>> zonesJson;
  final List<Map<String, dynamic>> heatmapsJson;
  final Map<String, String> cachedBoundaries; // osmId -> geoJson string

  _GeoJsonParams({
    required this.zonesJson,
    required this.heatmapsJson,
    required this.cachedBoundaries,
  });
}

/// Pure function that runs in an isolate to generate GeoJSON without blocking UI.
String _generateGeoJsonInIsolate(_GeoJsonParams params) {
  final List<Map<String, dynamic>> features = [];

  final heatmapMap = <int, Map<String, dynamic>>{};
  for (var h in params.heatmapsJson) {
    heatmapMap[h['zoneId'] as int] = h;
  }

  for (var zone in params.zonesJson) {
    final zoneId = zone['zoneId'] as int;
    final osmId = zone['osmId'] as int;
    final lat = (zone['centerLatitude'] as num).toDouble();
    final lng = (zone['centerLongitude'] as num).toDouble();
    final zoneName = zone['zoneName'] as String? ?? '';

    final heatmap = heatmapMap[zoneId];
    final demandLevel = heatmap?['demandLevel'] ?? 'NORMAL';
    final surgeMultiplier = heatmap?['surgeMultiplier'] ?? 1.0;
    final surgeMultiplierText = '${surgeMultiplier}x';
    final revenuePrediction = (heatmap?['revenuePrediction'] as num?)?.toDouble() ?? 0.0;

    // Try to use cached boundary geometry
    Map<String, dynamic>? geometry;
    final cachedGeo = params.cachedBoundaries[osmId.toString()];
    if (cachedGeo != null) {
      try {
        geometry = jsonDecode(cachedGeo) as Map<String, dynamic>;
      } catch (_) {}
    }

    // Skip zones without real OSM boundaries — no more ugly squares
    if (geometry == null || geometry['type'] == null) {
      continue;
    }

    features.add({
      "type": "Feature",
      "id": zoneId.toString(),
      "properties": {
        "zoneId": zoneId,
        "demandLevel": demandLevel,
        "surgeMultiplierText": surgeMultiplierText,
        "revenuePrediction": revenuePrediction,
        "zoneName": zoneName,
      },
      "geometry": geometry,
    });
  }

  return jsonEncode({
    "type": "FeatureCollection",
    "features": features,
  });
}

/// Generates a GeoJSON FeatureCollection using an isolate for performance.
Future<String> generateGeoJsonFromZones(
    List<ZoneModel> zones, List<ZoneHeatmapModel> heatmaps, ZoneBoundaryService boundaryService) async {

  // Pre-fetch all cached boundaries from Hive (on main thread, fast since it's local)
  final cachedBoundaries = <String, String>{};
  await boundaryService.initHive();
  final box = Hive.box<String>('zone_boundaries');
  for (var zone in zones) {
    final cached = box.get(zone.osmId.toString());
    if (cached != null) {
      cachedBoundaries[zone.osmId.toString()] = cached;
    }
  }

  // Serialize models to plain Maps for the isolate (Models can't cross isolate boundaries)
  final zonesJson = zones.map((z) => {
    'zoneId': z.zoneId,
    'osmId': z.osmId,
    'centerLatitude': z.centerLatitude,
    'centerLongitude': z.centerLongitude,
    'zoneName': z.zoneName,
  }).toList();

  final heatmapsJson = heatmaps.map((h) => {
    'zoneId': h.zoneId,
    'demandLevel': h.demandLevel,
    'surgeMultiplier': h.surgeMultiplier,
    'revenuePrediction': h.revenuePrediction,
  }).toList();

  return compute(
    _generateGeoJsonInIsolate,
    _GeoJsonParams(
      zonesJson: zonesJson,
      heatmapsJson: heatmapsJson,
      cachedBoundaries: cachedBoundaries,
    ),
  );
}

/// Generates a GeoJSON FeatureCollection of Points for Top Demand Zones
String generateTopDemandGeoJson(List<TopDemandZoneModel> topDemandZones) {
  final List<Map<String, dynamic>> features = topDemandZones.map((zone) {
    return {
      "type": "Feature",
      "id": "top_demand_${zone.zoneId}",
      "properties": {
        "zoneId": zone.zoneId,
        "zoneName": zone.zoneName,
        "demandPrediction": zone.demandPrediction,
        "percentageOfTotalPredicted": zone.percentageOfTotalPredicted,
      },
      "geometry": {
        "type": "Point",
        "coordinates": [zone.centerLongitude, zone.centerLatitude],
      },
    };
  }).toList();

  return jsonEncode({
    "type": "FeatureCollection",
    "features": features,
  });
}

class MapGridBloc extends Bloc<MapGridEvent, MapGridState> {
  final ZoneRepository repository;
  final ZoneBoundaryService boundaryService;
  StreamSubscription? _demandSubscription;
  
  // In-memory Look-up Table for O(1) time complexity mapping zoneId -> demandLevel
  final Map<int, int> _demandLookUp = {};
  final Map<int, ZoneHeatmapModel> _heatmapLookUp = {};
  
  String _currentGeoJson = "";

  MapGridBloc({required this.repository, required this.boundaryService}) : super(GridInitial()) {
    on<InitializeGrid>(_onInitializeGrid);
    on<UpdateLiveDemand>(_onUpdateLiveDemand);
    on<ZoneSelected>(_onZoneSelected);
    on<FetchZoneInsights>(_onFetchZoneInsights);
  }

  Future<void> _onInitializeGrid(InitializeGrid event, Emitter<MapGridState> emit) async {
    // 1. Offline-first: Check cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedGeoJson = prefs.getString('cached_heatmap');
      final cachedTopDemandGeoJson = prefs.getString('cached_top_demand');
      if (cachedGeoJson != null && cachedGeoJson.isNotEmpty) {
        _currentGeoJson = cachedGeoJson;
        if (!emit.isDone) {
          emit(GridReady(
            geoJson: _currentGeoJson,
            topDemandGeoJson: cachedTopDemandGeoJson,
            demandLookUp: Map.from(_demandLookUp),
            isRefreshing: true, // Show "Updating..." indicator
          ));
        }
      } else {
        if (!emit.isDone) emit(GridLoading());
      }
    } catch (e) {
      if (!emit.isDone) emit(GridLoading());
    }
    
    try {
      // 2. Fetch real zones, heatmap, and top demand from API
      final zonesResult = await repository.getZones();
      await Future.delayed(const Duration(milliseconds: 500)); // Server breather
      
      final heatmapResult = await repository.getZonesHeatmap();
      await Future.delayed(const Duration(milliseconds: 500)); // Server breather

      final topDemandResult = await repository.getTopDemandZones();
      
      await zonesResult.fold(
        (failure) async {},
        (zones) async {
          await heatmapResult.fold(
            (failure) async {},
            (heatmaps) async {
              for (var h in heatmaps) {
                _heatmapLookUp[h.zoneId] = h;
              }

              // Bulk fetch OSM boundaries if not cached
              final osmIds = zones.map((z) => z.osmId).toList();
              try {
                await boundaryService.fetchAndCacheBoundaries(osmIds);
              } catch (e) {
                debugPrint("Boundary bulk fetch failed: $e");
              }

              _currentGeoJson = await generateGeoJsonFromZones(zones, heatmaps, boundaryService);
              
              String? topDemandGeoJson;
              topDemandResult.fold(
                (failure) => null,
                (topDemandZones) {
                  topDemandGeoJson = generateTopDemandGeoJson(topDemandZones);
                }
              );

              // 3. Update cache
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('cached_heatmap', _currentGeoJson);
              if (topDemandGeoJson != null) {
                prefs.setString('cached_top_demand', topDemandGeoJson!);
              }
              
              if (!emit.isDone) {
                emit(GridReady(
                  geoJson: _currentGeoJson,
                  topDemandGeoJson: topDemandGeoJson,
                  demandLookUp: Map.from(_demandLookUp),
                  isRefreshing: false,
                ));
              }
            }
          );
        }
      );

      // 2. Subscribe to live demand updates from the repository
      _demandSubscription?.cancel();
      _demandSubscription = repository.getLiveDemandUpdates().listen((updates) {
        add(UpdateLiveDemand(updates));
      });
    } catch (e) {
      // Handle error gracefully in real implementation
    }
  }

  void _onUpdateLiveDemand(UpdateLiveDemand event, Emitter<MapGridState> emit) {
    // 1. Update the in-memory lookup table instantly with O(1) complexity
    for (var update in event.demandUpdates) {
      final zoneId = update['zoneId'] as int;
      final demandLevel = update['demandLevel'] as int;
      _demandLookUp[zoneId] = demandLevel;
    }

    // 2. Emit updated state with the latest updates for Mapbox to consume via setFeatureState
    emit(DemandUpdated(
      geoJson: _currentGeoJson,
      demandLookUp: Map.from(_demandLookUp),
      selectedZone: (state is GridReady) ? (state as GridReady).selectedZone : null,
      latestUpdates: event.demandUpdates,
    ));
  }
  
  void _onZoneSelected(ZoneSelected event, Emitter<MapGridState> emit) {
    if (state is GridReady) {
      final currentState = state as GridReady;
      emit(GridReady(
        geoJson: currentState.geoJson,
        demandLookUp: currentState.demandLookUp,
        selectedZone: _heatmapLookUp[event.zoneId],
        isRefreshing: currentState.isRefreshing,
      ));
    }
  }

  Future<void> _onFetchZoneInsights(FetchZoneInsights event, Emitter<MapGridState> emit) async {
    final currentState = state;
    if (currentState is GridReady) {
      emit(currentState.copyWith(isLoadingInsights: true, insightsError: null));
      
      final results = await Future.wait([
        repository.getZoneInsights(event.zoneId),
        repository.compareZones([event.zoneId]),
      ]);
      
      final insightsResult = results[0] as Either<Failure, ZoneInsightsModel>;
      final compareResult = results[1] as Either<Failure, List<ZoneComparisonModel>>;

      insightsResult.fold(
        (failure) => emit(currentState.copyWith(isLoadingInsights: false, insightsError: failure.message)),
        (insights) {
          List<ZoneComparisonModel>? comparisons;
          compareResult.fold(
            (failure) {
              debugPrint('Compare API Error: \${failure.message}');
            }, 
            (data) {
              comparisons = data;
              debugPrint('Compare API Success! Got \${data.length} comparisons.');
            }
          );
          
          emit(currentState.copyWith(
            isLoadingInsights: false, 
            insights: insights, 
            comparisons: comparisons,
            insightsError: null
          ));
        },
      );
    }
  }
  
  @override
  Future<void> close() {
    _demandSubscription?.cancel();
    return super.close();
  }
}
