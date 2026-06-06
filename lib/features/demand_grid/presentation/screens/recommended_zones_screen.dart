import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/widgets/recommended_zones_list.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';

class RecommendedZonesScreen extends StatelessWidget {
  const RecommendedZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // appColors.background equivalent
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Recommended Zones"),
        centerTitle: true,
      ),
      body: RecommendedZonesList(
        onZoneSelected: (zone) {
          // 1. Send event to map
          context.read<MapCubit>().flyToZone(zone.centerLatitude, zone.centerLongitude);
          
          // 2. Return to the previous screen (Analytics)
          Navigator.pop(context);
          
          // 3. Inform user to switch tabs
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Target set to ${zone.zoneName}. Switch to the Map tab to view!"),
              backgroundColor: Colors.greenAccent,
            ),
          );
        },
      ),
    );
  }
}
