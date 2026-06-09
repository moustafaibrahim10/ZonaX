import 'package:flutter/material.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import '../../data/models/zone_insights_model.dart';
import '../../data/models/zone_comparison_model.dart';

class ZoneDetailsBottomSheet extends StatelessWidget {
  final ZoneInsightsModel insights;
  final ZoneComparisonModel comparison;

  const ZoneDetailsBottomSheet({
    super.key,
    required this.insights,
    required this.comparison,
  });

  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // TabBar
              TabBar(
                indicatorColor: appColors.accent,
                labelColor: appColors.textPrimary,
                unselectedLabelColor: appColors.textSecondary,
                tabs: const [
                  Tab(text: "Performance", icon: Icon(Icons.analytics_outlined)),
                  Tab(text: "Comparison", icon: Icon(Icons.compare_arrows)),
                ],
              ),
              
              // TabBarView
              SizedBox(
                height: 300, // Fixed height for content
                child: TabBarView(
                  children: [
                    _buildPerformanceInsightsTab(appColors),
                    _buildComparisonStrategyTab(appColors),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceInsightsTab(AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoCard(
            appColors,
            title: "Avg Wait Time",
            value: "${insights.avgWaitTimeMinutes} mins",
            icon: Icons.timer,
            iconColor: Colors.orangeAccent,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            appColors,
            title: "Peak Period",
            value: insights.peakPeriodName,
            icon: Icons.access_time_filled,
            iconColor: Colors.purpleAccent,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            appColors,
            title: "Driver Efficiency",
            value: "${insights.driverEfficiencyScore.toStringAsFixed(1)} / 10",
            icon: Icons.speed,
            iconColor: Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonStrategyTab(AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: appColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Revenue Strategy",
                    style: TextStyle(color: appColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Divider(color: appColors.divider, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricColumn(appColors, "Current Total", "EGP ${comparison.totalRevenue.toStringAsFixed(2)}", appColors.textPrimary),
                      Icon(Icons.arrow_forward_ios, color: appColors.textHint, size: 16),
                      _buildMetricColumn(appColors, "Predicted (6H)", "EGP ${comparison.expectedRevenue6H.toStringAsFixed(2)}", Colors.blueAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            appColors,
            title: "Stockout Probability",
            value: "${(comparison.stockoutProbability * 100).toStringAsFixed(1)}%",
            icon: Icons.warning_amber_rounded,
            iconColor: comparison.stockoutProbability > 0.5 ? Colors.redAccent : Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppColors appColors, {required String title, required String value, required IconData icon, required Color iconColor}) {
    return Card(
      color: appColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: TextStyle(color: appColors.textSecondary, fontSize: 13)),
        subtitle: Text(value, style: TextStyle(color: appColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildMetricColumn(AppColors appColors, String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: appColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
