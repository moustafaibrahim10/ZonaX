import 'package:json_annotation/json_annotation.dart';

part 'driver_distribution_model.g.dart';

@JsonSerializable()
class DriverDistributionModel {
  @JsonKey(name: 'zoneId')
  final int zoneId;
  
  @JsonKey(name: 'activeDriversCount')
  final int activeDriversCount;
  
  @JsonKey(name: 'availableDriversCount')
  final int availableDriversCount;
  
  @JsonKey(name: 'onTripDriversCount')
  final int onTripDriversCount;
  
  @JsonKey(name: 'centerLatitude')
  final double centerLatitude;
  
  @JsonKey(name: 'centerLongitude')
  final double centerLongitude;

  @JsonKey(name: 'areaSizeProxy', defaultValue: 1.0)
  final double areaSizeProxy;

  DriverDistributionModel({
    required this.zoneId,
    required this.activeDriversCount,
    required this.availableDriversCount,
    required this.onTripDriversCount,
    required this.centerLatitude,
    required this.centerLongitude,
    this.areaSizeProxy = 1.0,
  });

  factory DriverDistributionModel.fromJson(Map<String, dynamic> json) => _$DriverDistributionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DriverDistributionModelToJson(this);
}
