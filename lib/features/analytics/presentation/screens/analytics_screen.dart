import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),
              Text(
                "This Week",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildThisWeekGrid(),
              SizedBox(height: 24.h),
              _buildSectionTitle("Earnings Trend"),
              _buildEarningsTrendChart(),
              SizedBox(height: 24.h),
              _buildSectionTitle("Peak Hours Performance"),
              _buildPeakHoursList(),
              SizedBox(height: 24.h),
              _buildSectionTitle("Top Earning Routes"),
              _buildTopRoutesList(),
              SizedBox(height: 24.h),
              _buildSectionTitle("Weekly Goals"),
              _buildWeeklyGoals(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Analytics",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Performance insights & trends",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThisWeekGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      children: [
        _buildStatCard(
          icon: Icons.attach_money,
          iconColor: Colors.greenAccent,
          label: "Total Earnings",
          value: "3,200 EGP",
          trend: "+18%",
          trendColor: Colors.greenAccent,
        ),
        _buildStatCard(
          icon: Icons.track_changes,
          iconColor: Colors.blueAccent,
          label: "Completed Trips",
          value: "78",
          trend: "+12%",
          trendColor: Colors.blueAccent,
        ),
        _buildStatCard(
          icon: Icons.access_time,
          iconColor: Colors.orangeAccent,
          label: "Online Hours",
          value: "42h",
          trend: "+5%",
          trendColor: Colors.orangeAccent,
        ),
        _buildStatCard(
          icon: Icons.trending_up,
          iconColor: Colors.tealAccent,
          label: "Avg. per Hour",
          value: "76 EGP",
          trend: "+15%",
          trendColor: Colors.tealAccent,
        ),
      ],
    );
  }

  Widget _buildStatCard({
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
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
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
                style: TextStyle(color: Colors.grey, fontSize: 11.sp),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
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

  Widget _buildEarningsTrendChart() {
    return Container(
      height: 180.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.4),
                _buildBar(0.7),
                _buildBar(0.5),
                _buildBar(0.9),
                _buildBar(0.6),
                _buildBar(0.8),
                _buildBar(0.4),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Weekly earnings for the last 4 weeks",
            style: TextStyle(color: Colors.grey, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor) {
    return Container(
      width: 20.w,
      height: 120.h * heightFactor,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent.withValues(alpha: 0.8), Colors.blueAccent.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _buildPeakHoursList() {
    return Column(
      children: [
        _buildPeakHourItem("6 AM - 9 AM", "12 trips - 520 EGP", 0.85, Colors.tealAccent),
        SizedBox(height: 12.h),
        _buildPeakHourItem("12 PM - 2 PM", "8 trips - 360 EGP", 0.70, Colors.tealAccent),
        SizedBox(height: 12.h),
        _buildPeakHourItem("5 PM - 8 PM", "18 trips - 850 EGP", 0.95, Colors.tealAccent),
        SizedBox(height: 12.h),
        _buildPeakHourItem("9 PM - 12 AM", "10 trips - 450 EGP", 0.75, Colors.tealAccent),
      ],
    );
  }

  Widget _buildPeakHourItem(String time, String stats, double progress, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  stats,
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
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
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6.h,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRoutesList() {
    return Column(
      children: [
        _buildRouteItem("Downtown → Airport", "15 trips this week", "82 EGP", "Trending", Colors.greenAccent),
        SizedBox(height: 12.h),
        _buildRouteItem("Business Bay → Mall", "12 trips this week", "54 EGP", "Trending", Colors.greenAccent),
        SizedBox(height: 12.h),
        _buildRouteItem("Airport → Downtown", "11 trips this week", "78 EGP", "Stable", Colors.grey),
      ],
    );
  }

  Widget _buildRouteItem(String route, String trips, String fare, String status, Color statusColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on, color: Colors.tealAccent, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  trips,
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fare,
                style: TextStyle(color: Colors.tealAccent, fontSize: 14.sp, fontWeight: FontWeight.bold),
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

  Widget _buildWeeklyGoals() {
    return Column(
      children: [
        _buildGoalItem("Earnings Goal", "3,200 / 4,000 EGP", 0.8),
        SizedBox(height: 16.h),
        _buildGoalItem("Trips Goal", "78 / 100 trips", 0.78),
      ],
    );
  }

  Widget _buildGoalItem(String title, String progressText, double progress) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              Text(progressText, style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }
}
