import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:zona_x_16_4/features/leaderboard/domain/entities/driver_entity.dart';
import 'package:zona_x_16_4/features/leaderboard/presentation/cubit/leaderboard_cubit.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<LeaderboardCubit>().getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      body: SafeArea(
        child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
          builder: (context, state) {
            if (state is LeaderboardLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(appColors.accent),
              ),
            );
          }

          if (state is LeaderboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 60.sp),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading leaderboard',
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () => context.read<LeaderboardCubit>().getLeaderboard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is LeaderboardLoaded) {
            final topThree = state.drivers.take(3).toList();
            final allDrivers = state.drivers;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.only(left: 20.w, top: 12.h, bottom: 8.h, right: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leaderboard',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: appColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Top drivers this month',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // Top 3 Podium
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // 2nd place (left)
                            if (topThree.length > 1)
                              Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: _buildPodiumCard(
                                  appColors,
                                  topThree[1],
                                  height: 140.h,
                                  width: 100.w,
                                ),
                              ),

                            // 1st place (center, tallest)
                            if (topThree.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: _buildPodiumCard(
                                  appColors,
                                  topThree[0],
                                  height: 180.h,
                                  width: 110.w,
                                  isTallest: true,
                                ),
                              ),

                            // 3rd place (right)
                            if (topThree.length > 2)
                              Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: _buildPodiumCard(
                                  appColors,
                                  topThree[2],
                                  height: 160.h,
                                  width: 100.w,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // All Drivers Section
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, bottom: 12.h, top: 20.h),
                    child: Text(
                      'All Drivers',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: appColors.textPrimary,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: List.generate(
                        allDrivers.length,
                        (index) => Column(
                          children: [
                            _buildDriverCard(appColors, allDrivers[index]),
                            if (index < allDrivers.length - 1) SizedBox(height: 12.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Achievements Section
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, bottom: 12.h),
                    child: Text(
                      'Your Achievements',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: appColors.textPrimary,
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAchievementCard(
                          appColors,
                          Icons.trending_up,
                          'Rising Star',
                          '+20% this week',
                          appColors.accent,
                        ),
                        SizedBox(width: 8.w),
                        _buildAchievementCard(
                          appColors,
                          Icons.emoji_events,
                          'Top 10',
                          'This month',
                          Colors.blue,
                        ),
                        SizedBox(width: 8.w),
                        _buildAchievementCard(
                          appColors,
                          Icons.bookmark,
                          '100+ Trips',
                          'This month',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Tip Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: appColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: appColors.inputBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: appColors.accent,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'Climb the Ranks',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: appColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Focus on high-demand zones during peak hours to maximize your earnings and improve your ranking.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: appColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 80.h), // Space for bottom nav
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'No data',
              style: TextStyle(color: appColors.textPrimary),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildPodiumCard(
    AppColors appColors,
    DriverEntity driver, {
    required double height,
    required double width,
    bool isTallest = false,
  }) {
    final rankColors = {
      1: appColors.accent,
      2: Colors.grey,
      3: Colors.orange,
    };

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 65.w,
            height: 65.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: rankColors[driver.rank] ?? appColors.accent,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (driver.rank == 1)
                    Icon(
                      Icons.emoji_events,
                      color: rankColors[driver.rank],
                      size: 28.sp,
                    )
                  else
                    Text(
                      '${driver.rank}',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: rankColors[driver.rank],
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  driver.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: appColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${driver.earnings.toStringAsFixed(0)} EGP',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: appColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(AppColors appColors, DriverEntity driver) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: driver.isCurrentUser
            ? appColors.accent.withValues(alpha: 0.1)
            : appColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: driver.isCurrentUser ? appColors.accent : appColors.inputBorder,
          width: driver.isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rank and Info
          Expanded(
            child: Row(
              children: [
                // Rank
                SizedBox(
                  width: 24.w,
                  child: Text(
                    '${driver.rank}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: appColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),

                // Icon/Badge
                _getRankBadge(appColors, driver),
                SizedBox(width: 8.w),

                // Name and Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              driver.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: appColors.textPrimary,
                              ),
                            ),
                          ),
                          if (driver.isCurrentUser) ...[
                            SizedBox(width: 4.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: appColors.accent,
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                  color: appColors.background,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        children: [
                          Text(
                            '${driver.trips} trips',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: appColors.textSecondary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.star, color: appColors.accent, size: 10.sp),
                          SizedBox(width: 2.w),
                          Text(
                            driver.rating.toString(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: appColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Earnings
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                driver.earnings.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: appColors.accent,
                ),
              ),
              Text(
                'EGP',
                style: TextStyle(
                  fontSize: 8.sp,
                  color: appColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getRankBadge(AppColors appColors, DriverEntity driver) {
    if (driver.rank == 1) {
      return Icon(Icons.emoji_events, color: appColors.accent, size: 20.sp);
    } else if (driver.rank == 2) {
      return Icon(Icons.shield, color: Colors.grey, size: 20.sp);
    } else if (driver.rank == 3) {
      return Icon(Icons.bookmark, color: Colors.orange, size: 20.sp);
    }
    return SizedBox(width: 20.w);
  }

  Widget _buildAchievementCard(
    AppColors appColors,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: appColors.inputBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 6.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: appColors.textPrimary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                color: appColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

