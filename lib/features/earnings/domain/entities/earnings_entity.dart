import 'package:equatable/equatable.dart';

class EarningsEntity extends Equatable {
  final EarningsHeaderSummaryEntity headerSummary;
  final EarningsPerformanceStatsEntity performanceStats;
  final List<dynamic> dailyBreakdown;
  final List<dynamic> recentTrips;

  const EarningsEntity({
    required this.headerSummary,
    required this.performanceStats,
    required this.dailyBreakdown,
    required this.recentTrips,
  });

  @override
  List<Object?> get props => [
        headerSummary,
        performanceStats,
        dailyBreakdown,
        recentTrips,
      ];
}

class EarningsHeaderSummaryEntity extends Equatable {
  final double totalEarnings;
  final int trips;
  final double hours;

  const EarningsHeaderSummaryEntity({
    required this.totalEarnings,
    required this.trips,
    required this.hours,
  });

  @override
  List<Object?> get props => [totalEarnings, trips, hours];
}

class EarningsPerformanceStatsEntity extends Equatable {
  final double avgPerTrip;
  final double earningsPerHour;
  final String trend;

  const EarningsPerformanceStatsEntity({
    required this.avgPerTrip,
    required this.earningsPerHour,
    required this.trend,
  });

  @override
  List<Object?> get props => [avgPerTrip, earningsPerHour, trend];
}
