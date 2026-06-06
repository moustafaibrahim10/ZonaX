// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_create_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripCreateDto _$TripCreateDtoFromJson(Map<String, dynamic> json) =>
    TripCreateDto(
      pickupLocationId: (json['pickupLocationId'] as num).toInt(),
      dropoffLocationId: (json['dropoffLocationId'] as num).toInt(),
      fareAmount: (json['fareAmount'] as num).toDouble(),
      tipAmount: (json['tipAmount'] as num).toDouble(),
      driverId: json['driverId'] as String,
    );

Map<String, dynamic> _$TripCreateDtoToJson(TripCreateDto instance) =>
    <String, dynamic>{
      'pickupLocationId': instance.pickupLocationId,
      'dropoffLocationId': instance.dropoffLocationId,
      'fareAmount': instance.fareAmount,
      'tipAmount': instance.tipAmount,
      'driverId': instance.driverId,
    };
