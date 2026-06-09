import 'package:equatable/equatable.dart';
import '../../data/models/zone_heatmap_model.dart';
import '../../data/models/zone_insights_model.dart';
import '../../data/models/zone_comparison_model.dart';

abstract class MapGridState extends Equatable {
  const MapGridState();
  
  @override
  List<Object?> get props => [];
}

class GridInitial extends MapGridState {}

class GridLoading extends MapGridState {}

class GridReady extends MapGridState {
  final String geoJson; // Grid GeoJSON
  final String? topDemandGeoJson; // High Demand Points GeoJSON
  final Map<int, int> demandLookUp; // O(1) lookup table
  final ZoneHeatmapModel? selectedZone;
  final ZoneInsightsModel? insights;
  final bool isLoadingInsights;
  final String? insightsError;
  final bool isRefreshing; // Tracks offline-first cache updates
  final List<ZoneComparisonModel>? comparisons;

  const GridReady({
    required this.geoJson,
    this.topDemandGeoJson,
    required this.demandLookUp,
    this.selectedZone,
    this.insights,
    this.isLoadingInsights = false,
    this.insightsError,
    this.isRefreshing = false,
    this.comparisons,
  });

  GridReady copyWith({
    String? geoJson,
    String? topDemandGeoJson,
    Map<int, int>? demandLookUp,
    ZoneHeatmapModel? selectedZone,
    ZoneInsightsModel? insights,
    bool? isLoadingInsights,
    String? insightsError,
    bool? isRefreshing,
    List<ZoneComparisonModel>? comparisons,
  }) {
    return GridReady(
      geoJson: geoJson ?? this.geoJson,
      topDemandGeoJson: topDemandGeoJson ?? this.topDemandGeoJson,
      demandLookUp: demandLookUp ?? this.demandLookUp,
      selectedZone: selectedZone ?? this.selectedZone,
      insights: insights ?? this.insights,
      isLoadingInsights: isLoadingInsights ?? this.isLoadingInsights,
      insightsError: insightsError ?? this.insightsError,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      comparisons: comparisons ?? this.comparisons,
    );
  }

  @override
  List<Object?> get props => [
    geoJson, 
    topDemandGeoJson,
    demandLookUp, 
    selectedZone,
    insights,
    isLoadingInsights,
    insightsError,
    isRefreshing,
    comparisons,
  ];
}

class DemandUpdated extends GridReady {
  final List<Map<String, dynamic>> latestUpdates; // Used by Mapbox to update only specific zones

  const DemandUpdated({
    required super.geoJson,
    super.topDemandGeoJson,
    required super.demandLookUp,
    super.selectedZone,
    super.insights,
    super.isLoadingInsights,
    super.insightsError,
    super.isRefreshing,
    super.comparisons,
    required this.latestUpdates,
  });

  @override
  List<Object?> get props => [
    geoJson, 
    topDemandGeoJson,
    demandLookUp, 
    selectedZone,
    insights,
    isLoadingInsights,
    insightsError,
    isRefreshing,
    comparisons,
    latestUpdates
  ];
}
