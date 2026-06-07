import '../../domain/entities/earnings_entity.dart';

class EarningsModel extends EarningsEntity {
  const EarningsModel({
    required super.headerSummary,
    required super.performanceStats,
    required super.dailyBreakdown,
    required super.recentTrips,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      headerSummary: EarningsHeaderSummaryModel.fromJson(json['headerSummary'] ?? {}),
      performanceStats: EarningsPerformanceStatsModel.fromJson(json['performanceStats'] ?? {}),
      dailyBreakdown: json['dailyBreakdown'] as List<dynamic>? ?? [],
      recentTrips: json['recentTrips'] as List<dynamic>? ?? [],
    );
  }
}

class EarningsHeaderSummaryModel extends EarningsHeaderSummaryEntity {
  const EarningsHeaderSummaryModel({
    required super.totalEarnings,
    required super.trips,
    required super.hours,
  });

  factory EarningsHeaderSummaryModel.fromJson(Map<String, dynamic> json) {
    return EarningsHeaderSummaryModel(
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      trips: json['trips'] as int? ?? 0,
      hours: (json['hours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EarningsPerformanceStatsModel extends EarningsPerformanceStatsEntity {
  const EarningsPerformanceStatsModel({
    required super.avgPerTrip,
    required super.earningsPerHour,
    required super.trend,
  });

  factory EarningsPerformanceStatsModel.fromJson(Map<String, dynamic> json) {
    return EarningsPerformanceStatsModel(
      avgPerTrip: (json['avg_per_trip'] as num?)?.toDouble() ?? 0.0,
      earningsPerHour: (json['earnings_per_hour'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend']?.toString() ?? "+0.0%",
    );
  }
}
