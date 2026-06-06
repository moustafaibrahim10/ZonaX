import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/recommended_zone_model.dart';
import '../bloc/recommended_zones_bloc.dart';
import '../bloc/recommended_zones_state.dart';

class RecommendedZonesList extends StatelessWidget {
  final void Function(RecommendedZoneModel) onZoneSelected;

  const RecommendedZonesList({super.key, required this.onZoneSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendedZonesBloc, RecommendedZonesState>(
      builder: (context, state) {
        if (state is RecommendedZonesLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        } else if (state is RecommendedZonesError) {
          return Center(
            child: Text(
              "Error: ${state.message}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        } else if (state is RecommendedZonesLoaded) {
          if (state.zones.isEmpty) {
            return const Center(
              child: Text(
                "No recommended zones found.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.zones.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final zone = state.zones[index];
              final isHighPotential = zone.predictedRevenueYield > 50;

              return InkWell(
                onTap: () => onZoneSelected(zone),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isHighPotential ? Colors.greenAccent.withOpacity(0.5) : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: [
                      if (isHighPotential)
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Leading Badge
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isHighPotential ? Colors.greenAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          zone.recommendationScore.toStringAsFixed(1),
                          style: TextStyle(
                            color: isHighPotential ? Colors.greenAccent : Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              zone.zoneName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              zone.reason,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[400], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Trailing Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "EGP ${zone.predictedRevenueYield.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.people_outline, color: Colors.grey[500], size: 14),
                              const SizedBox(width: 4),
                              Text(
                                zone.demandSupplyRatio.toStringAsFixed(1),
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
