import 'package:json_annotation/json_annotation.dart';

part 'trip_update_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class TripUpdateDto {
  final int? pickupLocationId;
  final int? dropoffLocationId;
  final double? fareAmount;
  final double? tipAmount;
  final String? processStatus;

  TripUpdateDto({
    this.pickupLocationId,
    this.dropoffLocationId,
    this.fareAmount,
    this.tipAmount,
    this.processStatus,
  });

  factory TripUpdateDto.fromJson(Map<String, dynamic> json) => _$TripUpdateDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TripUpdateDtoToJson(this);
}
