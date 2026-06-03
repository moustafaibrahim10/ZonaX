import 'package:equatable/equatable.dart';

abstract class MapGridState extends Equatable {
  const MapGridState();
  
  @override
  List<Object> get props => [];
}

class GridInitial extends MapGridState {}

class GridLoading extends MapGridState {}

class GridReady extends MapGridState {
  final String geoJson; // 16x16 Grid GeoJSON
  final Map<int, int> demandLookUp; // O(1) lookup table

  const GridReady({
    required this.geoJson,
    required this.demandLookUp,
  });

  @override
  List<Object> get props => [geoJson, demandLookUp];
}

class DemandUpdated extends GridReady {
  final List<Map<String, dynamic>> latestUpdates; // Used by Mapbox to update only specific zones

  const DemandUpdated({
    required super.geoJson,
    required super.demandLookUp,
    required this.latestUpdates,
  });

  @override
  List<Object> get props => [geoJson, demandLookUp, latestUpdates];
}
