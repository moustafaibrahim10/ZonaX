// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneModel _$ZoneModelFromJson(Map<String, dynamic> json) => ZoneModel(
  id: json['id'] as String,
  lat: (json['latitude'] as num).toDouble(),
  lng: (json['longitude'] as num).toDouble(),
  demandLevel: (json['intensity'] as num).toInt(),
);

Map<String, dynamic> _$ZoneModelToJson(ZoneModel instance) => <String, dynamic>{
  'id': instance.id,
  'latitude': instance.lat,
  'longitude': instance.lng,
  'intensity': instance.demandLevel,
};
