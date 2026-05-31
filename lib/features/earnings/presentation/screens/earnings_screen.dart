import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Earnings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildExportButton(),
          SizedBox(width: 16.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            _buildPeriodToggle(),
            SizedBox(height: 30.h),
            _buildMainSummary(),
            SizedBox(height: 30.h),
            Text(
              "Performance",
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildPerformanceGrid(),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daily Breakdown",
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                Text("View All", style: TextStyle(color: const Color(0xFF00D293), fontSize: 12.sp)),
              ],
            ),
            SizedBox(height: 16.h),
            _buildDailyBreakdown(),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Trips",
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                Text("View All >", style: TextStyle(color: const Color(0xFF00D293), fontSize: 12.sp)),
              ],
            ),
            SizedBox(height: 16.h),
            _buildRecentTripsList(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(Icons.ios_share, color: Colors.white, size: 16.sp),
          SizedBox(width: 6.w),
          Text("Export", style: TextStyle(color: Colors.white, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _buildToggleItem("Today", true),
          _buildToggleItem("Week", false),
          _buildToggleItem("Month", false),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00D293) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey,
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMainSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Earnings", style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                SizedBox(height: 4.h),
                Text(
                  "450 EGP",
                  style: TextStyle(color: Colors.white, fontSize: 32.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.attach_money, color: Colors.grey, size: 30.sp),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            _buildSmallSummaryItem("Trips", "12"),
            SizedBox(width: 40.w),
            _buildSmallSummaryItem("Hours Online", "6.5h"),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: const Color(0xFF00D293), fontSize: 12.sp)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPerformanceGrid() {
    return Row(
      children: [
        _buildPerformanceCard(Icons.attach_money, "Avg. per Trip", "38 EGP", "+15%", Colors.greenAccent),
        SizedBox(width: 12.w),
        _buildPerformanceCard(Icons.trending_up, "Per Hour", "69 EGP", "+22%", Colors.greenAccent),
      ],
    );
  }

  Widget _buildPerformanceCard(IconData icon, String label, String value, String trend, Color trendColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2A),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: const Color(0xFF00D293), size: 20.sp),
                Text(trend, style: TextStyle(color: trendColor, fontSize: 10.sp)),
              ],
            ),
            SizedBox(height: 12.h),
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBreakdown() {
    return Container(
      height: 180.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar("Mon", 520, 0.7),
          _buildBar("Tue", 480, 0.6),
          _buildBar("Wed", 650, 0.9),
          _buildBar("Thu", 590, 0.8),
          _buildBar("Fri", 450, 0.5),
        ],
      ),
    );
  }

  Widget _buildBar(String day, int amount, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(amount.toString(), style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 8.h),
        Container(
          width: 35.w,
          height: 100.h * heightFactor,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(height: 8.h),
        Text(day, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
      ],
    );
  }

  Widget _buildRecentTripsList() {
    return Column(
      children: [
        _buildTripCard("Downtown → Airport", "14:30", "25 min", "12.5 km", "85 EGP"),
        SizedBox(height: 12.h),
        _buildTripCard("Mall District → Business Bay", "13:45", "15 min", "7.2 km", "52 EGP"),
        SizedBox(height: 12.h),
        _buildTripCard("Residential → Downtown", "12:20", "18 min", "9.1 km", "38 EGP"),
        SizedBox(height: 12.h),
        _buildTripCard("Business Bay → Mall District", "11:30", "12 min", "5.8 km", "45 EGP"),
      ],
    );
  }

  Widget _buildTripCard(String route, String time, String duration, String distance, String fare) {
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
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: const Color(0xFF00D293), size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        route,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(fare, style: TextStyle(color: const Color(0xFF00D293), fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildTripDetail(Icons.access_time, time),
              SizedBox(width: 16.w),
              _buildTripDetail(Icons.timer_outlined, duration),
              SizedBox(width: 16.w),
              _buildTripDetail(Icons.route_outlined, distance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 14.sp),
        SizedBox(width: 4.w),
        Text(text, style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
      ],
    );
  }
}
