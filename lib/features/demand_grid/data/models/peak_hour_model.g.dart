// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peak_hour_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeakHourModel _$PeakHourModelFromJson(Map<String, dynamic> json) =>
    PeakHourModel(
      hour: (json['hour'] as num).toInt(),
      calculatedTripCount: (json['calculatedTripCount'] as num).toInt(),
      calculatedTotalRevenue: (json['calculatedTotalRevenue'] as num)
          .toDouble(),
      calculatedAverageFare: (json['calculatedAverageFare'] as num).toDouble(),
      predictedTripCount: (json['predictedTripCount'] as num).toInt(),
      predictedTotalRevenue: (json['predictedTotalRevenue'] as num).toDouble(),
      tripCount: (json['tripCount'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageFare: (json['averageFare'] as num).toDouble(),
    );

Map<String, dynamic> _$PeakHourModelToJson(PeakHourModel instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'calculatedTripCount': instance.calculatedTripCount,
      'calculatedTotalRevenue': instance.calculatedTotalRevenue,
      'calculatedAverageFare': instance.calculatedAverageFare,
      'predictedTripCount': instance.predictedTripCount,
      'predictedTotalRevenue': instance.predictedTotalRevenue,
      'tripCount': instance.tripCount,
      'totalRevenue': instance.totalRevenue,
      'averageFare': instance.averageFare,
    };
