import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_state.dart';
import '../../domain/entities/analytics_entity.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/screens/recommended_zones_screen.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/recommended_zones_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/recommended_zones_event.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';
import 'package:zona_x_16_4/features/analytics/presentation/bloc/peak_hours_bloc.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';
import 'package:zona_x_16_4/injection_container.dart' as di;

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      body: SafeArea(
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading || state is AnalyticsInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AnalyticsError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Colors.red, fontSize: 16.sp),
                ),
              );
            } else if (state is AnalyticsLoaded) {
              final analytics = state.analytics;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(appColors),
                    SizedBox(height: 24.h),
                    _buildRecommendedZonesBigButton(context, appColors),
                    SizedBox(height: 24.h),
                    Text(
                      "This Week",
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildThisWeekGrid(appColors, analytics.weeklySummary),
                    SizedBox(height: 24.h),
                    _buildSectionTitle(appColors, "Earnings Trend"),
                    _buildEarningsTrendChart(appColors, analytics.weeklySummary),
                    SizedBox(height: 24.h),
                    _buildSectionTitle(appColors, "Peak Hours Performance"),
                    _buildPeakHoursList(appColors),
                    SizedBox(height: 24.h),
                    _buildSectionTitle(appColors, "Top Earning Routes"),
                    _buildTopRoutesList(appColors, analytics.weeklySummary),
                    SizedBox(height: 24.h),
                    _buildSectionTitle(appColors, "Weekly Goals"),
                    _buildWeeklyGoals(appColors, analytics.weeklyGoals),
                    SizedBox(height: 40.h),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors appColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Analytics",
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Performance insights & trends",
          style: TextStyle(color: appColors.textSecondary, fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(AppColors appColors, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          color: appColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThisWeekGrid(AppColors appColors, WeeklySummaryEntity summary) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      children: [
        _buildStatCard(
          appColors,
          icon: Icons.attach_money,
          iconColor: appColors.accent,
          label: "Total Earnings",
          value: "${summary.totalEarnings.toStringAsFixed(0)} EGP",
          trend: "${summary.trends > 0 ? '+' : ''}${summary.trends}%",
          trendColor: summary.trends >= 0 ? appColors.accent : Colors.red,
        ),
        _buildStatCard(
          appColors,
          icon: Icons.track_changes,
          iconColor: Colors.blueAccent,
          label: "Completed Trips",
          value: "${summary.completedTrips}",
          trend: "+0%", // Dummy trend for trips since not in API
          trendColor: Colors.blueAccent,
        ),
        _buildStatCard(
          appColors,
          icon: Icons.access_time,
          iconColor: Colors.orangeAccent,
          label: "Online Hours",
          value: "${summary.onlineHours.toStringAsFixed(1)}h",
          trend: "+0%",
          trendColor: Colors.orangeAccent,
        ),
        _buildStatCard(
          appColors,
          icon: Icons.trending_up,
          iconColor: appColors.accent,
          label: "Avg. per Hour",
          value: "${summary.avgPerHour.toStringAsFixed(0)} EGP",
          trend: "+0%",
          trendColor: appColors.accent,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    AppColors appColors, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String trend,
    required Color trendColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20.sp),
              Text(
                trend,
                style: TextStyle(color: trendColor, fontSize: 10.sp),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: appColors.textSecondary, fontSize: 11.sp),
              ),
              Text(
                value,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTrendChart(AppColors appColors, WeeklySummaryEntity summary) {
    return Container(
      height: 180.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(appColors, 0.4),
                _buildBar(appColors, 0.7),
                _buildBar(appColors, 0.5),
                _buildBar(appColors, 0.9),
                _buildBar(appColors, 0.6),
                _buildBar(appColors, 0.8),
                _buildBar(appColors, 0.4),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Weekly earnings for the last 4 weeks",
            style: TextStyle(color: appColors.textSecondary, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(AppColors appColors, double heightFactor) {
    return Container(
      width: 20.w,
      height: 120.h * heightFactor,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appColors.accent.withValues(alpha: 0.8),
            appColors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _buildPeakHoursList(AppColors appColors) {
    return BlocBuilder<PeakHoursBloc, PeakHoursState>(
      builder: (context, state) {
        if (state is PeakHoursLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PeakHoursError) {
          return Center(
            child: Text(
              "Failed to load peak hours.",
              style: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
            ),
          );
        } else if (state is PeakHoursLoaded) {
          if (state.peakHours.isEmpty) {
            return Center(
              child: Text(
                "No peak hours data available.",
                style: TextStyle(color: appColors.textSecondary, fontSize: 14.sp),
              ),
            );
          }

          // Find max predicted trips for progress scaling
          final int maxTrips = state.peakHours
              .map((e) => e.predictedTripCount)
              .fold(0, (prev, element) => element > prev ? element : prev);

          return Column(
            children: state.peakHours.map((e) {
              final int hour = e.hour;
              final int trips = e.predictedTripCount;
              final double revenue = e.predictedTotalRevenue;
              
              // Format time to 12-hour AM/PM if needed, or keep 24-hour. We'll keep 24-hour as requested.
              final String timeLabel = '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00';
              final String stats = '$trips predicted trips - ${revenue.toStringAsFixed(0)} EGP';
              
              final double progress = maxTrips > 0 ? trips / maxTrips : 0.0;
              return Column(
                children: [
                  _buildPeakHourItem(appColors, timeLabel, stats, progress, appColors.accent),
                  SizedBox(height: 12.h),
                ],
              );
            }).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPeakHourItem(
    AppColors appColors,
    String time,
    String stats,
    double progress,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stats,
                  style: TextStyle(color: appColors.textSecondary, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: appColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6.h,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    color: color,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRoutesList(AppColors appColors, WeeklySummaryEntity summary) {
    return Column(
      children: [
        _buildRouteItem(
          appColors,
          "Downtown → Airport",
          "15 trips this week",
          "82 EGP",
          "Trending",
          appColors.accent,
        ),
        SizedBox(height: 12.h),
        _buildRouteItem(
          appColors,
          "Business Bay → Mall",
          "12 trips this week",
          "54 EGP",
          "Trending",
          appColors.accent,
        ),
        SizedBox(height: 12.h),
        _buildRouteItem(
          appColors,
          "Airport → Downtown",
          "11 trips this week",
          "78 EGP",
          "Stable",
          appColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildRouteItem(
    AppColors appColors,
    String route,
    String trips,
    String fare,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: appColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: appColors.accent,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  trips,
                  style: TextStyle(color: appColors.textSecondary, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fare,
                style: TextStyle(
                  color: appColors.accent,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 10.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoals(AppColors appColors, WeeklyGoalsEntity goals) {
    final earningsGoalProgress = goals.earningsGoal.target > 0 ? (goals.earningsGoal.current / goals.earningsGoal.target).clamp(0.0, 1.0) : 0.0;
    final tripsGoalProgress = goals.tripsGoal.target > 0 ? (goals.tripsGoal.current / goals.tripsGoal.target).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      children: [
        _buildGoalItem(appColors, "Earnings Goal", "${goals.earningsGoal.current.toStringAsFixed(0)} / ${goals.earningsGoal.target.toStringAsFixed(0)} EGP", earningsGoalProgress),
        SizedBox(height: 16.h),
        _buildGoalItem(appColors, "Trips Goal", "${goals.tripsGoal.current.toStringAsFixed(0)} / ${goals.tripsGoal.target.toStringAsFixed(0)} trips", tripsGoalProgress),
      ],
    );
  }

  Widget _buildGoalItem(AppColors appColors, String title, String progressText, double progress) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: appColors.textSecondary, fontSize: 12.sp),
              ),
              Text(
                progressText,
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: appColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                appColors.accent,
              ),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedZonesBigButton(BuildContext context, AppColors appColors) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => RecommendedZonesBloc(
                    repository: di.sl<ZoneRepository>(),
                  )..add(FetchRecommendedZones()),
                ),
                BlocProvider.value(
                  value: context.read<MapCubit>(),
                ),
              ],
              child: const RecommendedZonesScreen(),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appColors.surface,
              appColors.accent.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: appColors.accent.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: appColors.accent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star_rounded, color: appColors.accent, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recommended Zones",
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Discover high-demand areas to maximize your earnings.",
                    style: TextStyle(
                      color: appColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: appColors.accent, size: 16.sp),
          ],
        ),
      ),
    );
  }
}
