// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_update_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripUpdateDto _$TripUpdateDtoFromJson(Map<String, dynamic> json) =>
    TripUpdateDto(
      pickupLocationId: (json['pickupLocationId'] as num?)?.toInt(),
      dropoffLocationId: (json['dropoffLocationId'] as num?)?.toInt(),
      fareAmount: (json['fareAmount'] as num?)?.toDouble(),
      tipAmount: (json['tipAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TripUpdateDtoToJson(TripUpdateDto instance) =>
    <String, dynamic>{
      'pickupLocationId': ?instance.pickupLocationId,
      'dropoffLocationId': ?instance.dropoffLocationId,
      'fareAmount': ?instance.fareAmount,
      'tipAmount': ?instance.tipAmount,
    };
