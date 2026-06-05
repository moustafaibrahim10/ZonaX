import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:zona_x_16_4/core/utils/app_images.dart';
import 'package:zona_x_16_4/features/map/domain/entities/zone_entity.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_event.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_state.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/widgets/demand_grid_integration.dart';
import 'package:zona_x_16_4/features/profile/domain/usecases/update_driver_status_usecase.dart';
import 'package:zona_x_16_4/features/profile/data/repositories/driver_profile_repository_impl.dart';
import 'package:zona_x_16_4/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';
import 'package:zona_x_16_4/injection_container.dart' as di;

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> with WidgetsBindingObserver {
  MapboxMap? mapboxMap;
  late final UpdateDriverStatusUseCase _updateStatusUseCase;
  PointAnnotationManager? pointAnnotationManager;
  CircleAnnotationManager? circleAnnotationManager;
  PolygonAnnotationManager? polygonAnnotationManager;
  PointAnnotation? carPointAnnotation;
  bool isStyleLoaded = false;
  Uint8List? carIconBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _updateStatusUseCase = UpdateDriverStatusUseCase(
      DriverProfileRepositoryImpl(
        ProfileRemoteDataSourceImpl(),
      ),
    );
    
    // Initial status update
    _sendStatusUpdate("Available");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sendStatusUpdate("Available");
    } else if (state == AppLifecycleState.paused) {
      _sendStatusUpdate("Offline");
    }
  }

  void _sendStatusUpdate(String status) {
    // Tahrir Square fallback coordinates
    _updateStatusUseCase(status, 30.0444, 31.2357).then((result) {
      result.fold(
        (l) => debugPrint("Status update failed: ${l.message}"),
        (r) => debugPrint("Status updated to $status successfully."),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Dark background for nav area
      body: BlocProvider(
        create: (context) => MapGridBloc(repository: di.sl<ZoneRepository>())..add(InitializeGrid()),
        child: SafeArea(
          child: BlocBuilder<MapGridBloc, MapGridState>(
            buildWhen: (previous, current) => current is GridReady && previous is! GridReady,
            builder: (context, gridState) {
              return Stack(
                children: [
                  // 1. Mapbox Layer (Traffic Dark Mode)
                  MapWidget(
                    key: const ValueKey("mapWidget"),
                    cameraOptions: CameraOptions(
                      center: Point(coordinates: Position(31.2357, 30.0444)), // Tahrir Square
                      zoom: 12.5,
                    ),
                    styleUri: 'mapbox://styles/mapbox/traffic-night-v2', // Live Traffic Dark Theme
                    onMapCreated: (map) async {
                      setState(() {
                        mapboxMap = map;
                      });
                    },
                    onTapListener: (MapContentGestureContext tapContext) {
                      mapboxMap?.queryRenderedFeatures(
                        RenderedQueryGeometry.fromScreenCoordinate(tapContext.touchPosition),
                        RenderedQueryOptions(layerIds: ['demand-grid-layer'], filter: null),
                      ).then((features) {
                        if (features.isNotEmpty) {
                          final first = features.first;
                          if (first != null) {
                            final feature = first.queriedFeature.feature;
                            if (feature['properties'] != null) {
                              final zoneId = int.tryParse(feature['id']?.toString() ?? '');
                              if (zoneId != null) {
                                if (!mounted) return;
                                context.read<MapGridBloc>().add(FetchZoneInsights(zoneId: zoneId));
                                _showInsightsBottomSheet(context);
                              }
                            }
                          }
                        }
                      });
                    },

                    onStyleLoadedListener: (styleLoadedEvent) async {
                      isStyleLoaded = true;
                      final mapCubit = context.read<MapCubit>();
                      await _initAnnotationManagers();
                      await _setupUserLocation();
                      if (mounted) {
                        mapCubit.getZones();
                        // Draw car initially at Tahrir Square without moving
                        _updateCarPosition(30.0444, 31.2357);
                      }
                    },
            ),

            // 1.5. Demand Grid Layer
            if (mapboxMap != null && gridState is GridReady)
              DemandGridMapIntegration(
                mapboxMap: mapboxMap!,
                initialState: gridState,
              ),

          // Bloc Listener for map updates
          BlocListener<MapCubit, MapState>(
            listener: (context, state) {
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
      );
      },
    ),
  ),
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



  Widget _buildInsightCard() {
    final isSimulating = context.watch<MapCubit>().isSimulating;

    return BlocBuilder<MapGridBloc, MapGridState>(
      builder: (context, gridState) {
        String zoneName = "Tap a zone to see insights";
        String revenuePrediction = "EGP 0.00";
        String passengerProbability = "0% Passenger Probability";
        String waitTimeInfo = "ETA: N/A";
        String aiInsight = "Select a zone to get AI insights.";

        if (gridState is GridReady && gridState.selectedZone != null) {
          final zone = gridState.selectedZone!;
          zoneName = zone.zoneName;
          revenuePrediction = "EGP ${zone.revenuePrediction.toStringAsFixed(2)}";
          passengerProbability = "${(100 - zone.predictedStockoutProbability * 100).toInt()}% Passenger Probability";
          waitTimeInfo = "Trips: ${zone.predictedTripCount} | Wait: ~${(zone.predictedStockoutProbability * 10).toInt()} mins";
          aiInsight = "Demand Level is ${zone.demandLevel} with a ${zone.surgeMultiplier}x surge multiplier.";
        }

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
              boxShadow: const [
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
                        zoneName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      isSimulating ? Icons.stop_circle : Icons.play_circle_fill,
                      color: isSimulating ? Colors.red : Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  passengerProbability,
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                Text(
                  "Avg. Fare: $revenuePrediction. $waitTimeInfo.",
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                ),
                SizedBox(height: 10.h),
                Text(
                  aiInsight,
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        );
      },
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
  void _showInsightsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<MapGridBloc>(),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E2A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SafeArea(
              child: BlocBuilder<MapGridBloc, MapGridState>(
                builder: (context, state) {
                  if (state is ZoneInsightsLoading) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                    );
                  } else if (state is ZoneInsightsLoaded) {
                    final insights = state.insights;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40, height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Text(
                          "AI Zone Insights",
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        _buildInsightRow(Icons.lightbulb_outline, Colors.amber, "AI Insight", insights.aiInsightText ?? "No specific insight available."),
                        const SizedBox(height: 10),
                        _buildInsightRow(Icons.trending_up, Colors.greenAccent, "Demand Growth", "${insights.demandGrowthPercentage ?? 0.0}%"),
                        const SizedBox(height: 10),
                        _buildInsightRow(Icons.check_circle_outline, Colors.blueAccent, "Recommendation", insights.recommendedAction ?? "Maintain current operations."),
                        const SizedBox(height: 20),
                      ],
                    );
                  } else if (state is ZoneInsightsError) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.redAccent)),
                      ),
                    );
                  }
                  return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightRow(IconData icon, Color color, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
