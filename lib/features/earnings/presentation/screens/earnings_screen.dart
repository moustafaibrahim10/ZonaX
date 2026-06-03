import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _selectedPeriod = "Today";

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Earnings",
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildExportButton(appColors),
          SizedBox(width: 16.w),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              _buildPeriodToggle(appColors),
              SizedBox(height: 30.h),
              _buildMainSummary(appColors),
              SizedBox(height: 30.h),
              Text(
                "Performance",
                style: TextStyle(
                  color: appColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildPerformanceGrid(appColors),
              SizedBox(height: 30.h),
              _buildTrendSection(appColors),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Daily Breakdown",
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "View All",
                    style: TextStyle(
                      color: appColors.accent,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildDailyBreakdown(appColors),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Trips",
                    style: TextStyle(
                      color: appColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "View All >",
                    style: TextStyle(
                      color: appColors.accent,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildRecentTripsList(appColors),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton(AppColors appColors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.ios_share, color: appColors.accent, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            "Export",
            style: TextStyle(color: appColors.textPrimary, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodToggle(AppColors appColors) {
    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        children: [
          _buildToggleItem(appColors, "Today"),
          _buildToggleItem(appColors, "Week"),
          _buildToggleItem(appColors, "Month"),
        ],
      ),
    );
  }

  Widget _buildToggleItem(AppColors appColors, String label) {
    final isActive = _selectedPeriod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = label;
          });
        },
        child: Container(
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isActive ? appColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? appColors.background : appColors.textSecondary,
              fontSize: 14.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainSummary(AppColors appColors) {
    String earnings = "450 EGP";
    String trips = "12";
    String hours = "6.5h";

    if (_selectedPeriod == "Week") {
      earnings = "3,200 EGP";
      trips = "78";
      hours = "42h";
    } else if (_selectedPeriod == "Month") {
      earnings = "12,500 EGP";
      trips = "310";
      hours = "160h";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Earnings",
                  style: TextStyle(color: appColors.textSecondary, fontSize: 12.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  earnings,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: appColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: appColors.inputBorder),
              ),
              child: Icon(Icons.attach_money, color: appColors.accent, size: 30.sp),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            _buildSmallSummaryItem(appColors, "Trips", trips),
            SizedBox(width: 40.w),
            _buildSmallSummaryItem(appColors, "Hours Online", hours),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallSummaryItem(AppColors appColors, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: appColors.accent, fontSize: 12.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceGrid(AppColors appColors) {
    return Row(
      children: [
        _buildPerformanceCard(
          appColors,
          Icons.attach_money,
          "Avg. per Trip",
          "38 EGP",
          "+15%",
          Colors.greenAccent,
        ),
        SizedBox(width: 12.w),
        _buildPerformanceCard(
          appColors,
          Icons.trending_up,
          "Per Hour",
          "69 EGP",
          "+22%",
          Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(
    AppColors appColors,
    IconData icon,
    String label,
    String value,
    String trend,
    Color trendColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: appColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: appColors.accent, size: 20.sp),
                Text(
                  trend,
                  style: TextStyle(color: trendColor, fontSize: 10.sp),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(color: appColors.textSecondary, fontSize: 12.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyBreakdown(AppColors appColors) {
    return Container(
      height: 180.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: appColors.inputBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar(appColors, "Mon", 520, 0.7),
          _buildBar(appColors, "Tue", 480, 0.6),
          _buildBar(appColors, "Wed", 650, 0.9),
          _buildBar(appColors, "Thu", 590, 0.8),
          _buildBar(appColors, "Fri", 450, 0.5),
        ],
      ),
    );
  }

  Widget _buildBar(AppColors appColors, String day, int amount, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          amount.toString(),
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 35.w,
          height: 100.h * heightFactor,
          decoration: BoxDecoration(
            color: appColors.accent,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          day,
          style: TextStyle(color: appColors.textSecondary, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildRecentTripsList(AppColors appColors) {
    return Column(
      children: [
        _buildTripCard(
          appColors,
          "Downtown → Airport",
          "14:30",
          "25 min",
          "12.5 km",
          "85 EGP",
        ),
        SizedBox(height: 12.h),
        _buildTripCard(
          appColors,
          "Mall District → Business Bay",
          "13:45",
          "15 min",
          "7.2 km",
          "52 EGP",
        ),
        SizedBox(height: 12.h),
        _buildTripCard(
          appColors,
          "Residential → Downtown",
          "12:20",
          "18 min",
          "9.1 km",
          "38 EGP",
        ),
        SizedBox(height: 12.h),
        _buildTripCard(
          appColors,
          "Business Bay → Mall District",
          "11:30",
          "12 min",
          "5.8 km",
          "45 EGP",
        ),
      ],
    );
  }

  Widget _buildTripCard(
    AppColors appColors,
    String route,
    String time,
    String duration,
    String distance,
    String fare,
  ) {
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
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: appColors.accent,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        route,
                        style: TextStyle(
                          color: appColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                fare,
                style: TextStyle(
                  color: appColors.accent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildTripDetail(appColors, Icons.access_time, time),
              SizedBox(width: 16.w),
              _buildTripDetail(appColors, Icons.timer_outlined, duration),
              SizedBox(width: 16.w),
              _buildTripDetail(appColors, Icons.route_outlined, distance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetail(AppColors appColors, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: appColors.textSecondary, size: 14.sp),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(color: appColors.textSecondary, fontSize: 12.sp),
        ),
      ],
    );
  }

  // Trend section (mock data fallback)
  Widget _buildTrendSection(AppColors appColors) {
    final List<dynamic> trends = [
      {
        'periodLabel': '2026-03-07',
        'tripCount': 2,
        'averageFare': 227.86,
        'totalRevenue': 455.72,
      },
      {
        'periodLabel': '2026-03-08',
        'tripCount': 1,
        'averageFare': 246.18,
        'totalRevenue': 246.18,
      },
      // Add more mock items as needed
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Trends',
          style: TextStyle(
            color: appColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 150.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trends.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final item = trends[index];
              return Container(
                width: 120.w,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: appColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: appColors.inputBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['periodLabel'],
                      style: TextStyle(
                        color: appColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${item['tripCount']} trips',
                      style: TextStyle(
                        color: appColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${item['totalRevenue'].toStringAsFixed(0)} EGP',
                      style: TextStyle(
                        color: appColors.accent,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
