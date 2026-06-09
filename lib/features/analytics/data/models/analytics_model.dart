import '../../domain/entities/analytics_entity.dart';

class AnalyticsModel extends AnalyticsEntity {
  const AnalyticsModel({
    required super.weeklySummary,
    required super.weeklyGoals,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    final earningsTrend = json['earningsTrend'] as List<dynamic>? ?? [];
    final peakHours = json['peakHours'] as List<dynamic>? ?? [];
    final topRoutes = json['topRoutes'] as List<dynamic>? ?? [];

    final weeklySummaryJson = json['weeklySummary'] ?? {};
    
    return AnalyticsModel(
      weeklySummary: WeeklySummaryModel.fromJson(weeklySummaryJson, earningsTrend, peakHours, topRoutes),
      weeklyGoals: WeeklyGoalsModel.fromJson(json['weeklyGoals'] ?? {}),
    );
  }
}

class WeeklySummaryModel extends WeeklySummaryEntity {
  const WeeklySummaryModel({
    required super.totalEarnings,
    required super.completedTrips,
    required super.onlineHours,
    required super.avgPerHour,
    required super.trends,
    required super.earningsTrend,
    required super.peakHours,
    required super.topRoutes,
  });

  factory WeeklySummaryModel.fromJson(
    Map<String, dynamic> json, 
    List<dynamic> earningsTrendRoot,
    List<dynamic> peakHoursRoot,
    List<dynamic> topRoutesRoot,
  ) {
    double parsedTrends = 0.0;
    if (json['trends'] is List && (json['trends'] as List).isNotEmpty) {
      final firstTrend = (json['trends'] as List).first.toString();
      final cleaned = firstTrend.replaceAll('%', '').replaceAll('+', '');
      parsedTrends = double.tryParse(cleaned) ?? 0.0;
    }

    return WeeklySummaryModel(
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      completedTrips: json['completed_trips'] as int? ?? 0,
      onlineHours: (json['online_hours'] as num?)?.toDouble() ?? 0.0,
      avgPerHour: (json['avg_per_hour'] as num?)?.toDouble() ?? 0.0,
      trends: parsedTrends,
      earningsTrend: earningsTrendRoot,
      peakHours: peakHoursRoot,
      topRoutes: topRoutesRoot,
    );
  }
}

class WeeklyGoalsModel extends WeeklyGoalsEntity {
  const WeeklyGoalsModel({
    required super.earningsGoal,
    required super.tripsGoal,
  });

  factory WeeklyGoalsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalsModel(
      earningsGoal: GoalModel.fromJson(json['earnings_goal'] ?? {}),
      tripsGoal: GoalModel.fromJson(json['trips_goal'] ?? {}),
    );
  }
}

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.current,
    required super.target,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      current: (json['current'] as num?)?.toDouble() ?? 0.0,
      target: (json['target'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
