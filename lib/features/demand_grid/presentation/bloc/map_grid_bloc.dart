import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/zone_repository.dart';
import 'map_grid_event.dart';
import 'map_grid_state.dart';
import '../../data/models/zone_model.dart';
import '../../data/models/zone_heatmap_model.dart';
import 'dart:convert';

/// Generates a GeoJSON FeatureCollection of square polygons from a list of real zones and their heatmap data.
String generateGeoJsonFromZones(List<ZoneModel> zones, List<ZoneHeatmapModel> heatmaps) {
  final List<Map<String, dynamic>> features = [];
  final heatmapMap = {for (var h in heatmaps) h.zoneId: h};

  for (var zone in zones) {
    final heatmap = heatmapMap[zone.zoneId];
    final demandLevel = heatmap?.demandLevel ?? 'NORMAL';
    final surgeMultiplierText = heatmap != null ? '${heatmap.surgeMultiplier}x' : '1.0x';
    final revenuePrediction = heatmap?.revenuePrediction ?? 0.0;

    double offset = 0.002; // Square cell radius/offset
    double lat = zone.centerLatitude;
    double lng = zone.centerLongitude;

    features.add({
      "type": "Feature",
      "id": zone.zoneId.toString(),
      "properties": {
        "demandLevel": demandLevel,
        "surgeMultiplierText": surgeMultiplierText,
        "revenuePrediction": revenuePrediction,
        "zoneName": zone.zoneName,
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [lng - offset, lat + offset], // Top-Left
          [lng + offset, lat + offset], // Top-Right
          [lng + offset, lat - offset], // Bottom-Right
          [lng - offset, lat - offset], // Bottom-Left
          [lng - offset, lat + offset], // Top-Left
        ]]
      }
    });
  }

  return jsonEncode({
    "type": "FeatureCollection",
    "features": features,
  });
}

class MapGridBloc extends Bloc<MapGridEvent, MapGridState> {
  final ZoneRepository repository;
  StreamSubscription? _demandSubscription;
  
  // In-memory Look-up Table for O(1) time complexity mapping zoneId -> demandLevel
  final Map<int, int> _demandLookUp = {};
  final Map<int, ZoneHeatmapModel> _heatmapLookUp = {};
  
  String _currentGeoJson = "";

  MapGridBloc({required this.repository}) : super(GridInitial()) {
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
      if (cachedGeoJson != null && cachedGeoJson.isNotEmpty) {
        _currentGeoJson = cachedGeoJson;
        emit(GridReady(
          geoJson: _currentGeoJson,
          demandLookUp: Map.from(_demandLookUp),
          isRefreshing: true, // Show "Updating..." indicator
        ));
      } else {
        emit(GridLoading());
      }
    } catch (e) {
      emit(GridLoading());
    }
    
    try {
      // 2. Fetch real zones and heatmap from API sequentially with breathers
      final zonesResult = await repository.getZones();
      await Future.delayed(const Duration(milliseconds: 500)); // Server breather
      
      final heatmapResult = await repository.getZonesHeatmap();
      
      zonesResult.fold(
        (failure) {},
        (zones) {
          heatmapResult.fold(
            (failure) {},
            (heatmaps) {
              for (var h in heatmaps) {
                _heatmapLookUp[h.zoneId] = h;
              }
              _currentGeoJson = generateGeoJsonFromZones(zones, heatmaps);
              
              // 3. Update cache
              SharedPreferences.getInstance().then((prefs) {
                prefs.setString('cached_heatmap', _currentGeoJson);
              });
              
              emit(GridReady(
                geoJson: _currentGeoJson,
                demandLookUp: Map.from(_demandLookUp),
                isRefreshing: false,
              ));
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
    // We emit the loading state but we don't want to wipe out the GridReady state from the UI if possible.
    // However, since MapGridState is replaced, the UI might need to handle this or we just emit a side-effect state.
    // Let's just emit ZoneInsightsLoading.
    emit(ZoneInsightsLoading());
    final result = await repository.getZoneInsights(event.zoneId);
    result.fold(
      (failure) => emit(ZoneInsightsError(failure.message)),
      (insights) => emit(ZoneInsightsLoaded(insights)),
    );
  }
  
  @override
  Future<void> close() {
    _demandSubscription?.cancel();
    return super.close();
  }
}
