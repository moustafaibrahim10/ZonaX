import 'package:json_annotation/json_annotation.dart';

part 'trip_create_dto.g.dart';

@JsonSerializable()
class TripCreateDto {
  final int pickupLocationId;
  final int dropoffLocationId;
  final double fareAmount;
  final double tipAmount;

  TripCreateDto({
    required this.pickupLocationId,
    required this.dropoffLocationId,
    required this.fareAmount,
    required this.tipAmount,
  });

  factory TripCreateDto.fromJson(Map<String, dynamic> json) => _$TripCreateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TripCreateDtoToJson(this);
}
