import 'package:equatable/equatable.dart';
import '../../data/models/zone_heatmap_model.dart';
import '../../data/models/zone_insights_model.dart';

abstract class MapGridState extends Equatable {
  const MapGridState();
  
  @override
  List<Object> get props => [];
}

class GridInitial extends MapGridState {}

class GridLoading extends MapGridState {}

class GridReady extends MapGridState {
  final String geoJson; // Grid GeoJSON
  final Map<int, int> demandLookUp; // O(1) lookup table
  final ZoneHeatmapModel? selectedZone;
  final bool isRefreshing; // Tracks offline-first cache updates

  const GridReady({
    required this.geoJson,
    required this.demandLookUp,
    this.selectedZone,
    this.isRefreshing = false,
  });

  @override
  List<Object> get props => [
    geoJson, 
    demandLookUp, 
    if (selectedZone != null) selectedZone!,
    isRefreshing,
  ];
}

class DemandUpdated extends GridReady {
  final List<Map<String, dynamic>> latestUpdates; // Used by Mapbox to update only specific zones

  const DemandUpdated({
    required super.geoJson,
    required super.demandLookUp,
    super.selectedZone,
    super.isRefreshing,
    required this.latestUpdates,
  });

  @override
  List<Object> get props => [
    geoJson, 
    demandLookUp, 
    if (selectedZone != null) selectedZone!,
    isRefreshing,
    latestUpdates
  ];
}

class ZoneInsightsLoading extends MapGridState {}

class ZoneInsightsLoaded extends MapGridState {
  final ZoneInsightsModel insights;

  const ZoneInsightsLoaded(this.insights);

  @override
  List<Object> get props => [insights];
}

class ZoneInsightsError extends MapGridState {
  final String message;

  const ZoneInsightsError(this.message);

  @override
  List<Object> get props => [message];
}
