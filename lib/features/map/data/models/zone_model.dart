import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/zone_entity.dart';

part 'zone_model.g.dart';

@JsonSerializable()
class ZoneModel extends ZoneEntity {
  @override
  @JsonKey(name: 'latitude')
  final double lat;

  @override
  @JsonKey(name: 'longitude')
  final double lng;

  @override
  @JsonKey(name: 'demand_level')
  final int demandLevel;

  @override
  @JsonKey(name: 'is_high_profit')
  final bool isHighProfit;

  @override
  @JsonKey(name: 'forecast_msg')
  final String forecastMsg;

  const ZoneModel({
    required super.id,
    required this.lat,
    required this.lng,
    required this.demandLevel,
    required this.isHighProfit,
    required this.forecastMsg,
  }) : super(
          lat: lat,
          lng: lng,
          demandLevel: demandLevel,
          isHighProfit: isHighProfit,
          forecastMsg: forecastMsg,
        );

  factory ZoneModel.fromJson(Map<String, dynamic> json) =>
      _$ZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneModelToJson(this);
}
