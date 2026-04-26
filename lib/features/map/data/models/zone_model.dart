import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/zone_entity.dart';

part 'zone_model.g.dart'; 

@JsonSerializable()
class ZoneModel extends ZoneEntity {
  
  const ZoneModel({
    required String id,
    @JsonKey(name: 'latitude') required double lat,
    @JsonKey(name: 'longitude') required double lng,
    @JsonKey(name: 'demand_level') required int demandLevel,
    @JsonKey(name: 'is_high_profit') required bool isHighProfit,
    @JsonKey(name: 'forecast_msg') required String forecastMsg,
  }) : super(
          id: id,
          lat: lat,
          lng: lng,
          demandLevel: demandLevel,
          isHighProfit: isHighProfit,
          forecastMsg: forecastMsg,
        );

  factory ZoneModel.fromJson(Map<String, dynamic> json) => _$ZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneModelToJson(this);
}