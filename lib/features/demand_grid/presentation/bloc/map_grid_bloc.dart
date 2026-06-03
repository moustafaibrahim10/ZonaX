import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/zone_repository.dart';
import 'map_grid_event.dart';
import 'map_grid_state.dart';
import '../../data/mock/cairo_districts_geojson.dart';
import 'dart:convert';

/// Generates an organic GeoJSON grid of real Cairo districts.
/// Injects a deterministic `static_demand` property into each feature based on its id.
String generateMockCairoGrid() {
  final Map<String, dynamic> parsed = jsonDecode(organicCairoDistrictsGeoJson);
  final List<dynamic> features = parsed['features'];

  for (var feature in features) {
    int id = int.parse(feature['id'].toString());
    int staticDemand;
    if (id % 3 == 0) {
      staticDemand = 95; // Red Surge zones
    } else if (id % 2 == 0) {
      staticDemand = 55; // Yellow Medium zones
    } else {
      staticDemand = 15; // Green Low-demand zones
    }

    feature['properties'] ??= {};
    feature['properties']['static_demand'] = staticDemand;
  }

  return jsonEncode(parsed);
}

class MapGridBloc extends Bloc<MapGridEvent, MapGridState> {
  final ZoneRepository repository;
  StreamSubscription? _demandSubscription;
  
  // In-memory Look-up Table for O(1) time complexity mapping zoneId -> demandLevel
  final Map<int, int> _demandLookUp = {};
  
  String _currentGeoJson = "";

  MapGridBloc({required this.repository}) : super(GridInitial()) {
    on<InitializeGrid>(_onInitializeGrid);
    on<UpdateLiveDemand>(_onUpdateLiveDemand);
  }

  Future<void> _onInitializeGrid(InitializeGrid event, Emitter<MapGridState> emit) async {
    emit(GridLoading());
    
    try {
      // 1. Generate the initial grid using your local function
      _currentGeoJson = generateMockCairoGrid();
      
      emit(GridReady(
        geoJson: _currentGeoJson,
        demandLookUp: Map.from(_demandLookUp),
      ));

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
      latestUpdates: event.demandUpdates,
    ));
  }
  
  @override
  Future<void> close() {
    _demandSubscription?.cancel();
    return super.close();
  }
}
