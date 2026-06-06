part of 'map_cubit.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapZonesLoaded extends MapState {
  final List<ZoneEntity> zones;

  const MapZonesLoaded(this.zones);

  @override
  List<Object?> get props => [zones];
}

class MapCarMoving extends MapState {
  final double lat;
  final double lng;
  final double bearing;

  const MapCarMoving({
    required this.lat,
    required this.lng,
    this.bearing = 0.0,
  });

  @override
  List<Object?> get props => [lat, lng, bearing];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}

class MapFlyToLocation extends MapState {
  final double lat;
  final double lng;

  const MapFlyToLocation(this.lat, this.lng);

  @override
  List<Object?> get props => [lat, lng];
}

class MapSimulationCompleted extends MapState {}
