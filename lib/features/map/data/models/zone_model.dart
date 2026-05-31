import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/zone_entity.dart';

part 'zone_model.g.dart'; 

@JsonSerializable()
class ZoneModel extends ZoneEntity {
  
  const ZoneModel({
    required super.id,
    @JsonKey(name: 'latitude') required super.lat,
    @JsonKey(name: 'longitude') required super.lng,
    @JsonKey(name: 'demand_level') required super.demandLevel,
    @JsonKey(name: 'is_high_profit') required super.isHighProfit,
    @JsonKey(name: 'forecast_msg') required super.forecastMsg,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) => _$ZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$ZoneModelToJson(this);
}