import 'package:flutter/material.dart';
import 'package:zona_x_16_4/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/widgets/recommended_zones_list.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';

class RecommendedZonesScreen extends StatelessWidget {
  const RecommendedZonesScreen({super.key});

  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Recommended Zones", style: TextStyle(color: appColors.textPrimary)),
        iconTheme: IconThemeData(color: appColors.textPrimary),
        centerTitle: true,
      ),
      body: RecommendedZonesList(
        onZoneSelected: (zone) {
          // 1. Send event to map
          context.read<MapCubit>().flyToZone(zone.centerLatitude, zone.centerLongitude);
          
          // 2. Return to the previous screen (Analytics) with a success flag
          Navigator.pop(context, true);
          
          // 3. Inform user (shorter, no need to ask them to switch)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Target set to ${zone.zoneName}."),
              backgroundColor: Colors.greenAccent,
            ),
          );
        },
      ),
    );
  }
}
