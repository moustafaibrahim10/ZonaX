import 'package:json_annotation/json_annotation.dart';

part 'trip_create_dto.g.dart';

@JsonSerializable()
class TripCreateDto {
  final int pickupLocationId;
  final int dropoffLocationId;
  final double fareAmount;
  final double tipAmount;
  final String driverId;

  TripCreateDto({
    required this.pickupLocationId,
    required this.dropoffLocationId,
    required this.fareAmount,
    required this.tipAmount,
    required this.driverId,
  });

  factory TripCreateDto.fromJson(Map<String, dynamic> json) => _$TripCreateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TripCreateDtoToJson(this);
}
