import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:zona_x_16_4/core/utils/app_images.dart';
import 'package:zona_x_16_4/features/map/domain/entities/zone_entity.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  CircleAnnotationManager? circleAnnotationManager;
  PolygonAnnotationManager? polygonAnnotationManager;
  PointAnnotation? carPointAnnotation;
  bool isStyleLoaded = false;
  Uint8List? carIconBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Dark background for nav area
      body: Stack(
        children: [
          // 1. Mapbox Layer (Traffic Dark Mode)
          MapWidget(
            key: const ValueKey("mapWidget"),
            styleUri:
                'mapbox://styles/mapbox/traffic-night-v2', // Live Traffic Dark Theme
            onMapCreated: (map) async {
              mapboxMap = map;
            },
            onStyleLoadedListener: (styleLoadedEvent) async {
              isStyleLoaded = true;
              final mapCubit = context.read<MapCubit>();
              await _initAnnotationManagers();
              await _setupUserLocation();
              if (mounted) {
                mapCubit.getZones();
                // Draw car initially at starting point without moving
                _updateCarPosition(30.14488, 31.63581);
              }
            },
          ),

          // Bloc Listener for map updates
          BlocListener<MapCubit, MapState>(
            listener: (context, state) {
              if (state is MapZonesLoaded && isStyleLoaded) {
                _drawHeatmapPolygons(state.zones);
              }
              if (state is MapCarMoving && isStyleLoaded) {
                _updateCarPosition(state.lat, state.lng);
              }
            },
            child: const SizedBox.shrink(),
          ),

          // Loading Indicator
          BlocBuilder<MapCubit, MapState>(
            builder: (context, state) {
              if (state is MapLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            },
          ),

          // Overlays with SafeArea
          SafeArea(
            child: Stack(
              children: [
                // 2. Top Voice Visualizer
                Positioned(
                  top: 15.h,
                  left: 15.w,
                  right: 15.w,
                  child: _buildVoiceAssistantBar(),
                ),

                // 3. Left Sidebar Buttons
                Positioned(top: 100.h, left: 15.w, child: _buildSidebar()),

                // 4. Bottom Insight Card
                Positioned(
                  bottom: 15.h,
                  left: 15.w,
                  right: 15.w,
                  child: _buildInsightCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildVoiceAssistantBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // Simulated Voice Waveform
          Icon(Icons.graphic_eq, color: Colors.redAccent, size: 28.sp),
          SizedBox(width: 10.w),
          Icon(Icons.mic, color: Colors.blueAccent, size: 24.sp),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Listening for command...",
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
                Text(
                  "\"Find high demand\"",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        _buildSideButton(Icons.cloud_off, "Offline\nMode", Colors.grey),
        SizedBox(height: 10.h),
        _buildSideButton(
          Icons.battery_charging_full,
          "Battery\nSaver",
          Colors.green,
        ),
        SizedBox(height: 10.h),
        _buildSideButton(Icons.insert_chart, "Data\nUsage", Colors.blueAccent),
      ],
    );
  }

  Widget _buildSideButton(IconData icon, String label, Color iconColor) {
    return Container(
      width: 60.w,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24.sp),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10.sp,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    // We add a GestureDetector to toggle simulation here as a bonus!
    final isSimulating = context.watch<MapCubit>().isSimulating;

    return GestureDetector(
      onTap: () {
        context.read<MapCubit>().toggleSimulation();
      },
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: const Color(0xFF191B28).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Head to Zone 102 (Midtown East).",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Simulation Status Icon
                Icon(
                  isSimulating ? Icons.stop_circle : Icons.play_circle_fill,
                  color: isSimulating ? Colors.red : Colors.green,
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Text(
              "90% Passenger Probability.",
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            Text(
              "Avg. Fare: \$25. ETA: 5 mins.",
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              "AI Insight: High evening commute traffic & weather forecast suggests surge in 10 mins.",
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  // --- Mapbox Logic ---

  Future<void> _initAnnotationManagers() async {
    polygonAnnotationManager = await mapboxMap?.annotations
        .createPolygonAnnotationManager();
    pointAnnotationManager = await mapboxMap?.annotations
        .createPointAnnotationManager();
    circleAnnotationManager = await mapboxMap?.annotations
        .createCircleAnnotationManager();
  }

  void _drawHeatmapPolygons(List<ZoneEntity> zones) async {
    polygonAnnotationManager?.deleteAll();

    for (var zone in zones) {
      double offset = 0.002; // Decreased size to prevent overlapping
      List<Position> polygonPoints = [
        Position(zone.lng - offset, zone.lat - offset),
        Position(zone.lng + offset, zone.lat - offset),
        Position(zone.lng + offset, zone.lat + offset),
        Position(zone.lng - offset, zone.lat + offset),
        Position(zone.lng - offset, zone.lat - offset),
      ];

      int fillColor;
      if (zone.demandLevel > 7) {
        fillColor = Colors.red.toARGB32();
      } else if (zone.demandLevel > 4) {
        fillColor = Colors.orangeAccent.toARGB32();
      } else {
        fillColor = Colors.green.withValues(alpha: 0.5).toARGB32();
      }

      // 1. Draw glowing polygon
      polygonAnnotationManager?.create(
        PolygonAnnotationOptions(
          geometry: Polygon(coordinates: [polygonPoints]),
          fillColor: fillColor,
          fillOpacity: 0.3,
          fillOutlineColor: fillColor, // Match outline to create glow effect
        ),
      );

      // 2. Draw $ pin inside the polygon
      pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: Position(zone.lng, zone.lat)),
          textField: "💲",
          textSize: 22.0,
          textHaloColor: Colors.black87.toARGB32(),
          textHaloWidth: 1.0,
        ),
      );
    }
  }

  void _updateCarPosition(double lat, double lng) async {
    final position = Position(lng, lat);

    if (carPointAnnotation == null) {
      if (carIconBytes == null) return; // Wait for asset to load
      carPointAnnotation = await pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: position),
          image: carIconBytes,
          iconSize: 0.04, // Size matched to normal Uber-like apps
        ),
      );
    } else {
      carPointAnnotation?.geometry = Point(coordinates: position);
      pointAnnotationManager?.update(carPointAnnotation!);
    }

    mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: position), zoom: 16.0),
      MapAnimationOptions(duration: 1000),
    );
  }

  Future<void> _setupUserLocation() async {
    try {
      // 1. Load the explicit asset to Uint8List
      final ByteData bytes = await rootBundle.load(AppImages.carIcon);
      final Uint8List list = bytes.buffer.asUint8List();
      carIconBytes = list;

      // 2. Add style image
      await mapboxMap?.style.addStyleImage(
        'zona-x-driver-car',
        1.0,
        MbxImage(width: 100, height: 100, data: list),
        false,
        [],
        [],
        null,
      );

      // 3. Configure LocationComponentSettings with the injected image
      await mapboxMap?.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          puckBearingEnabled: true,
          puckBearing: PuckBearing.COURSE,
          locationPuck: LocationPuck(
            locationPuck2D: LocationPuck2D(
              topImage: list,
              bearingImage: list,
              shadowImage: list,
              scaleExpression: '0.04', // Scale down the location puck
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error loading advanced user location puck: $e");
    }
  }
}
