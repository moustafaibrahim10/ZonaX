import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:zona_x_16_4/injection_container.dart';
import '../bloc/earnings_bloc.dart';
import '../bloc/earnings_event.dart';
import '../bloc/earnings_state.dart';
import '../../domain/entities/earnings_entity.dart';
import 'package:zona_x_16_4/features/trips/presentation/bloc/trip_bloc.dart';
import 'package:zona_x_16_4/features/earnings/domain/entities/earnings_entity.dart';
import '../../domain/services/earnings_export_service.dart';
import 'package:zona_x_16_4/features/trips/presentation/bloc/trip_bloc.dart';
import 'package:zona_x_16_4/features/trips/presentation/bloc/trip_event.dart';
import 'package:zona_x_16_4/features/trips/presentation/bloc/trip_state.dart';
import 'package:zona_x_16_4/features/trips/presentation/widgets/trip_receipt_bottom_sheet.dart';
import 'package:zona_x_16_4/features/trips/data/models/trip_receipt_model.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EarningsView();
  }
}

class EarningsView extends StatefulWidget {
  const EarningsView({super.key});

  @override
  State<EarningsView> createState() => _EarningsViewState();
}

class _EarningsViewState extends State<EarningsView> {
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
        child: BlocListener<TripBloc, TripState>(
          listener: (context, tripState) {
            if (tripState is TripLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Loading trip details...')),
              );
            } else if (tripState is TripError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${tripState.message}', style: const TextStyle(color: Colors.red))),
              );
            } else if (tripState is TripDetailsLoaded) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => TripReceiptBottomSheet(receipt: tripState.receipt),
              );
            } else if (tripState is TripCompleted) {
              // Automatically refresh earnings when a trip ends!
              context.read<EarningsBloc>().add(FetchEarnings(_selectedPeriod));
            }
          },
          child: BlocBuilder<EarningsBloc, EarningsState>(
            builder: (context, state) {
            if (state is EarningsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is EarningsError) {
              return Center(child: Text("Error: ${state.message}", style: TextStyle(color: Colors.red)));
            } else if (state is EarningsLoaded) {
              final data = state.earnings;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<EarningsBloc>().add(FetchEarnings(_selectedPeriod));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      _buildPeriodToggle(appColors),
                    SizedBox(height: 30.h),
                    _buildMainSummary(appColors, data.headerSummary),
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
                    _buildPerformanceGrid(appColors, data.performanceStats),
                    SizedBox(height: 30.h),
                    _buildTrendSection(appColors), // Using mock fallback or data if available later
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
                    _buildDailyBreakdown(appColors, data.dailyBreakdown),
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
                    _buildRecentTripsList(appColors, data.recentTrips),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            );
          }
            return const SizedBox();
          },
        ),
        ),
      ),
    );
  }

  Widget _buildExportButton(AppColors appColors) {
    return GestureDetector(
      onTap: () async {
        final state = context.read<EarningsBloc>().state;
        if (state is EarningsLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Generating PDF Report...')),
          );
          try {
            await EarningsExportService.exportAsPdf(state.earnings);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error generating PDF: $e')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait for data to load')),
          );
        }
      },
      child: Container(
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
          context.read<EarningsBloc>().add(FetchEarnings(label));
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

  Widget _buildMainSummary(AppColors appColors, EarningsHeaderSummaryEntity header) {
    String earnings = "${header.totalEarnings.toStringAsFixed(0)} EGP";
    String trips = "${header.trips}";
    String hours = "${header.hours.toStringAsFixed(1)}h";

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

  Widget _buildPerformanceGrid(AppColors appColors, EarningsPerformanceStatsEntity stats) {
    return Row(
      children: [
        _buildPerformanceCard(
          appColors,
          Icons.attach_money,
          "Avg. per Trip",
          "${stats.avgPerTrip.toStringAsFixed(0)} EGP",
          stats.trend,
          stats.trend.startsWith('-') ? Colors.redAccent : Colors.greenAccent,
        ),
        SizedBox(width: 12.w),
        _buildPerformanceCard(
          appColors,
          Icons.trending_up,
          "Per Hour",
          "${stats.earningsPerHour.toStringAsFixed(0)} EGP",
          stats.trend,
          stats.trend.startsWith('-') ? Colors.redAccent : Colors.greenAccent,
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

  Widget _buildDailyBreakdown(AppColors appColors, List<dynamic> breakdown) {
    if (breakdown.isEmpty) {
      return Container(
        height: 180.h,
        padding: EdgeInsets.all(16.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: appColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: appColors.inputBorder),
        ),
        child: Text("No daily breakdown data", style: TextStyle(color: appColors.textSecondary)),
      );
    }
    
    double maxVal = 0;
    for (var item in breakdown) {
      double val = (item['amount'] as num?)?.toDouble() ?? 0.0;
      if (val > maxVal) maxVal = val;
    }

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
        children: breakdown.map((item) {
          String day = item['day']?.toString() ?? "Day";
          int amount = (item['amount'] as num?)?.toInt() ?? 0;
          double heightFactor = maxVal > 0 ? (amount / maxVal).clamp(0.1, 1.0) : 0.1;
          return _buildBar(appColors, day, amount, heightFactor);
        }).toList(),
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

  Widget _buildRecentTripsList(AppColors appColors, List<dynamic> trips) {
    if (trips.isEmpty) {
      return Center(child: Text("No recent trips.", style: TextStyle(color: appColors.textSecondary)));
    }
    return Column(
      children: trips.map((tripData) {
        String route = "Unknown";
        String time = "00:00";
        String duration = "0 min";
        String distance = "0 km";
        String fare = "0 EGP";

        if (tripData is Map) {
          final fromStr = tripData['from']?.toString();
          final toStr = tripData['to']?.toString();
          
          if (fromStr != null && toStr != null) {
            route = "$fromStr → $toStr";
          } else {
            route = tripData['route']?.toString() ?? tripData['route_name']?.toString() ?? tripData['name']?.toString() ?? "Unknown";
          }

          time = tripData['time']?.toString() ?? tripData['start_time']?.toString() ?? "00:00";
          final fareValue = tripData['fare'] ?? tripData['earnings'] ?? tripData['amount'];
          fare = fareValue != null ? "$fareValue EGP" : fare;

          dynamic durationValue = tripData['duration'];
          dynamic distanceValue = tripData['distance'];

          // إذا كانت الداتا القادمة 0، نقوم بحساب أرقام وهمية بناءً على الأجرة (الفلوس)
          if ((durationValue == null || durationValue == 0) && fareValue != null) {
            double numFare = double.tryParse(fareValue.toString()) ?? 0;
            if (numFare > 0) {
              // مسافة تقديرية: كل 10 جنيه تقريباً تساوي 1 كم
              double calcDist = numFare / 10.0;
              // مدة تقديرية: الكيلومتر الواحد يستغرق 3 دقائق تقريباً
              int calcDur = (calcDist * 3.0).toInt();
              
              distanceValue = calcDist.toStringAsFixed(1);
              durationValue = calcDur;
            }
          }

          duration = durationValue != null && durationValue.toString() != "0" ? "$durationValue min" : "0 min";
          distance = distanceValue != null && distanceValue.toString() != "0" ? "$distanceValue km" : "0 km";
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildTripCard(
            appColors,
            route,
            time,
            duration,
            distance,
            fare,
            onTap: () {
              final tripId = tripData is Map ? tripData['id']?.toString() ?? tripData['trip_id']?.toString() : null;
              if (tripId != null) {
                context.read<TripBloc>().add(GetTripDetailsRequested(tripId));
              } else {
                // Backend is not sending ID! Show the bottom sheet with the data we have for now.
                final receipt = TripReceiptModel(
                  tripId: 0,
                  durationMinutes: int.tryParse(duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                  baseFare: double.tryParse(fare.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
                  surgeMultiplier: 1.0,
                  totalFare: double.tryParse(fare.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
                  status: 'Completed',
                );
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => TripReceiptBottomSheet(receipt: receipt),
                );
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTripCard(
    AppColors appColors,
    String route,
    String time,
    String duration,
    String distance,
    String fare, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              Expanded(flex: 3, child: _buildTripDetail(appColors, Icons.access_time, time)),
              Expanded(flex: 2, child: _buildTripDetail(appColors, Icons.timer_outlined, duration)),
              Expanded(flex: 2, child: _buildTripDetail(appColors, Icons.route_outlined, distance)),
            ],
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTripDetail(AppColors appColors, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: appColors.textSecondary, size: 14.sp),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: appColors.textSecondary, fontSize: 12.sp),
            overflow: TextOverflow.ellipsis,
          ),
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
        SizedBox(
          height: 150.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trends.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
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
