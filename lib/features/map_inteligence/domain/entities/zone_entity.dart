import 'package:equatable/equatable.dart';

class ZoneEntity extends Equatable {
  final String id;
  final double lat;
  final double lng;
  final int demandLevel;

  const ZoneEntity({
    required this.id,
    required this.lat,
    required this.lng,
    required this.demandLevel,
  });

  @override
  List<Object?> get props => [id, lat, lng, demandLevel];
}