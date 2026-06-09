import 'package:json_annotation/json_annotation.dart';

part 'peak_hour_model.g.dart';

@JsonSerializable()
class PeakHourModel {
  @JsonKey(name: 'hour')
  final int hour;
  
  @JsonKey(name: 'calculatedTripCount')
  final int calculatedTripCount;
  
  @JsonKey(name: 'calculatedTotalRevenue')
  final double calculatedTotalRevenue;
  
  @JsonKey(name: 'calculatedAverageFare')
  final double calculatedAverageFare;
  
  @JsonKey(name: 'predictedTripCount')
  final int predictedTripCount;
  
  @JsonKey(name: 'predictedTotalRevenue')
  final double predictedTotalRevenue;
  
  @JsonKey(name: 'tripCount')
  final int tripCount;
  
  @JsonKey(name: 'totalRevenue')
  final double totalRevenue;
  
  @JsonKey(name: 'averageFare')
  final double averageFare;

  PeakHourModel({
    required this.hour,
    required this.calculatedTripCount,
    required this.calculatedTotalRevenue,
    required this.calculatedAverageFare,
    required this.predictedTripCount,
    required this.predictedTotalRevenue,
    required this.tripCount,
    required this.totalRevenue,
    required this.averageFare,
  });

  factory PeakHourModel.fromJson(Map<String, dynamic> json) => _$PeakHourModelFromJson(json);

  Map<String, dynamic> toJson() => _$PeakHourModelToJson(this);
}
