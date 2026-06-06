import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/zone_insights_model.dart';
import '../../data/models/zone_comparison_model.dart';
import '../../data/models/driver_distribution_model.dart';
import '../../presentation/bloc/map_grid_bloc.dart';
import '../../presentation/bloc/map_grid_event.dart';
import '../../presentation/bloc/map_grid_state.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/widgets/create_trip_bottom_sheet.dart';

class UnifiedZoneDetailsBottomSheet extends StatelessWidget {
  final ZoneInsightsModel? insights;
  final ZoneComparisonModel? comparison;
  final DriverDistributionModel? driverDistribution;
  final String zoneName;
  final int zoneId;
  final VoidCallback onCreateTripTap;

  const UnifiedZoneDetailsBottomSheet({
    super.key,
    this.insights,
    this.comparison,
    this.driverDistribution,
    required this.zoneName,
    required this.zoneId,
    required this.onCreateTripTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: DefaultTabController(
          length: 3,
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
              
              Text(
                zoneName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // TabBar
              const TabBar(
                indicatorColor: Colors.blueAccent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                isScrollable: true,
                tabs: [
                  Tab(text: "Insights", icon: Icon(Icons.analytics_outlined)),
                  Tab(text: "Drivers", icon: Icon(Icons.local_taxi)),
                  Tab(text: "Strategy", icon: Icon(Icons.compare_arrows)),
                ],
              ),
              
              // TabBarView
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _buildPerformanceInsightsTab(),
                    _buildDriverDistributionTab(),
                    _buildComparisonStrategyTab(),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              
              // Create Trip Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCreateTripTap,
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text(
                    'Create Trip in this Zone',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceInsightsTab() {
    if (insights == null) {
      return const Center(child: Text("No insights available.", style: TextStyle(color: Colors.grey)));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          _buildInfoCard(
            title: "Avg Wait Time",
            value: "${insights!.avgWaitTimeMinutes} mins",
            icon: Icons.timer,
            iconColor: Colors.orangeAccent,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: "Peak Period",
            value: insights!.peakPeriodName,
            icon: Icons.access_time_filled,
            iconColor: Colors.purpleAccent,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: "Driver Efficiency",
            value: "${insights!.driverEfficiencyScore.toStringAsFixed(1)} / 10",
            icon: Icons.speed,
            iconColor: Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildDriverDistributionTab() {
    if (driverDistribution == null) {
      return const Center(child: Text("No driver data available.", style: TextStyle(color: Colors.grey)));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDriverStatCard("Available", driverDistribution!.availableDriversCount.toString(), Colors.greenAccent),
              _buildDriverStatCard("On Trip", driverDistribution!.onTripDriversCount.toString(), Colors.amberAccent),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            title: "Active Drivers",
            value: driverDistribution!.activeDriversCount.toString(),
            icon: Icons.person_pin_circle,
            iconColor: Colors.blueAccent,
          )
        ],
      ),
    );
  }

  Widget _buildDriverStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F3F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonStrategyTab() {
    if (comparison == null) {
      return const Center(child: Text("No strategy data available.", style: TextStyle(color: Colors.grey)));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Card(
            color: const Color(0xFF2A2A3A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Revenue Strategy",
                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricColumn("Current Total", "EGP ${comparison!.totalRevenue.toStringAsFixed(2)}", Colors.white),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                      _buildMetricColumn("Predicted (6H)", "EGP ${comparison!.expectedRevenue6H.toStringAsFixed(2)}", Colors.blueAccent),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: "Stockout Probability",
            value: "${(comparison!.stockoutProbability * 100).toStringAsFixed(1)}%",
            icon: Icons.warning_amber_rounded,
            iconColor: comparison!.stockoutProbability > 0.5 ? Colors.redAccent : Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required IconData icon, required Color iconColor}) {
    return Card(
      color: const Color(0xFF2A2A3A),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.2), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
