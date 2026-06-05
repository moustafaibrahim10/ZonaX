import 'package:equatable/equatable.dart';

abstract class MapGridEvent extends Equatable {
  const MapGridEvent();

  @override
  List<Object> get props => [];
}

class InitializeGrid extends MapGridEvent {}

class UpdateLiveDemand extends MapGridEvent {
  final List<Map<String, dynamic>> demandUpdates;

  const UpdateLiveDemand(this.demandUpdates);

  @override
  List<Object> get props => [demandUpdates];
}

class ZoneSelected extends MapGridEvent {
  final int zoneId;

  const ZoneSelected(this.zoneId);

  @override
  List<Object> get props => [zoneId];
}

class FetchZoneInsights extends MapGridEvent {
  final int zoneId;

  const FetchZoneInsights({required this.zoneId});

  @override
  List<Object> get props => [zoneId];
}
