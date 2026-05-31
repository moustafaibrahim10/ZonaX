// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneModel _$ZoneModelFromJson(Map<String, dynamic> json) => ZoneModel(
  id: json['id'] as String,
  lat: (json['latitude'] as num).toDouble(),
  lng: (json['longitude'] as num).toDouble(),
  demandLevel: (json['demand_level'] as num).toInt(),
  isHighProfit: json['is_high_profit'] as bool,
  forecastMsg: json['forecast_msg'] as String,
);

Map<String, dynamic> _$ZoneModelToJson(ZoneModel instance) => <String, dynamic>{
  'id': instance.id,
  'latitude': instance.lat,
  'longitude': instance.lng,
  'demand_level': instance.demandLevel,
  'is_high_profit': instance.isHighProfit,
  'forecast_msg': instance.forecastMsg,
};
