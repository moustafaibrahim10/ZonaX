import 'package:equatable/equatable.dart';

class ZoneEntity extends Equatable {
  final String id;
  final double lat;
  final double lng;
  final int demandLevel;
  final bool isHighProfit;
  final String forecastMsg;

  const ZoneEntity({
    required this.id,
    required this.lat,
    required this.lng,
    required this.demandLevel,
    required this.isHighProfit,
    required this.forecastMsg,
  });

  @override
  List<Object?> get props => [
    id,
    lat,
    lng,
    demandLevel,
    isHighProfit,
    forecastMsg,
  ];
}
