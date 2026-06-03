import 'package:equatable/equatable.dart';

class AnalyticsEntity extends Equatable {
  final WeeklySummaryEntity weeklySummary;
  final WeeklyGoalsEntity weeklyGoals;

  const AnalyticsEntity({
    required this.weeklySummary,
    required this.weeklyGoals,
  });

  @override
  List<Object?> get props => [weeklySummary, weeklyGoals];
}

class WeeklySummaryEntity extends Equatable {
  final double totalEarnings;
  final int completedTrips;
  final double onlineHours;
  final double avgPerHour;
  final double trends;
  final List<dynamic> earningsTrend;
  final List<dynamic> peakHours;
  final List<dynamic> topRoutes;

  const WeeklySummaryEntity({
    required this.totalEarnings,
    required this.completedTrips,
    required this.onlineHours,
    required this.avgPerHour,
    required this.trends,
    required this.earningsTrend,
    required this.peakHours,
    required this.topRoutes,
  });

  @override
  List<Object?> get props => [
        totalEarnings,
        completedTrips,
        onlineHours,
        avgPerHour,
        trends,
        earningsTrend,
        peakHours,
        topRoutes,
      ];
}

class WeeklyGoalsEntity extends Equatable {
  final GoalEntity earningsGoal;
  final GoalEntity tripsGoal;

  const WeeklyGoalsEntity({
    required this.earningsGoal,
    required this.tripsGoal,
  });

  @override
  List<Object?> get props => [earningsGoal, tripsGoal];
}

class GoalEntity extends Equatable {
  final double current;
  final double target;

  const GoalEntity({
    required this.current,
    required this.target,
  });

  @override
  List<Object?> get props => [current, target];
}
