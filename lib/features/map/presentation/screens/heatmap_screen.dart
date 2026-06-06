import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:zona_x_16_4/core/utils/app_images.dart';
import 'package:zona_x_16_4/features/map/domain/entities/zone_entity.dart';
import 'package:zona_x_16_4/features/map/presentation/cubit/map_cubit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_event.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/map_grid_state.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/bloc/driver_distribution_bloc.dart';
import 'package:zona_x_16_4/features/trips/presentation/bloc/trip_bloc.dart';
import 'package:zona_x_16_4/features/trips/presentation/widgets/create_trip_bottom_sheet.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/widgets/demand_grid_integration.dart';
import 'package:zona_x_16_4/features/demand_grid/data/models/zone_comparison_model.dart';
import 'package:zona_x_16_4/features/demand_grid/data/models/zone_insights_model.dart';
import 'package:zona_x_16_4/features/profile/domain/usecases/update_driver_status_usecase.dart';
import 'package:zona_x_16_4/features/profile/data/repositories/driver_profile_repository_impl.dart';
import 'package:zona_x_16_4/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';
import 'package:zona_x_16_4/features/demand_grid/data/datasources/zone_boundary_service.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/widgets/unified_zone_details_bottom_sheet.dart';
import 'package:zona_x_16_4/features/demand_grid/data/models/driver_distribution_model.dart';
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
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MapGridBloc(repository: di.sl<ZoneRepository>(), boundaryService: di.sl<ZoneBoundaryService>())..add(InitializeGrid()),
          ),
          BlocProvider(
            create: (context) => DriverDistributionBloc(repository: di.sl<ZoneRepository>())
              ..add(StartPollingDriverDistribution()),
          ),
        ],
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
                        RenderedQueryOptions(layerIds: ['driver-distribution-layer', 'top-demand-layer', 'demand-grid-layer'], filter: null),
                      ).then((features) {
                        if (features.isNotEmpty) {
                          final first = features.first;
                          if (first != null) {
                            final feature = first.queriedFeature.feature;
                            if (feature['properties'] != null) {
                              final props = feature['properties'] as Map;
                              
                              if (props.containsKey('availableDriversCount')) {
                                // It's a driver distribution feature
                                final zoneId = props['zoneId'] as int;
                                final zoneName = props['zoneName']?.toString() ?? 'Unknown Zone';
                                if (!mounted) return;
                                context.read<MapGridBloc>().add(FetchZoneInsights(zoneId: zoneId));
                                _showUnifiedZoneBottomSheet(context, zoneId, zoneName);
                              } else if (props.containsKey('demandPrediction') && props.containsKey('percentageOfTotalPredicted')) {
                                // It's a top-demand feature
                                final zoneId = props['zoneId'] as int;
                                final zoneName = props['zoneName']?.toString() ?? 'Hotspot';
                                if (!mounted) return;
                                context.read<MapGridBloc>().add(FetchZoneInsights(zoneId: zoneId));
                                // Highlight the zone explicitly (handled by bloc state update)
                                context.read<MapGridBloc>().add(ZoneSelected(zoneId));
                                _showUnifiedZoneBottomSheet(context, zoneId, zoneName);
                              } else {
                                // It's a zone feature
                                final zoneId = int.tryParse(feature['id']?.toString() ?? '');
                                final zoneName = props['zoneName']?.toString() ?? 'Zone $zoneId';
                                if (zoneId != null) {
                                  if (!mounted) return;
                                  context.read<MapGridBloc>().add(FetchZoneInsights(zoneId: zoneId));
                                  _showUnifiedZoneBottomSheet(context, zoneId, zoneName);
                                }
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
                if (state is MapCarMoving) {
                  _updateCarPosition(state.lat, state.lng);
                } else if (state is MapFlyToLocation) {
                  mapboxMap?.flyTo(
                    CameraOptions(
                      center: Point(coordinates: Position(state.lng, state.lat)),
                      zoom: 14.0,
                    ),
                    MapAnimationOptions(duration: 1500),
                  );
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
                SizedBox(height: 15.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final zId = (gridState is GridReady && gridState.selectedZone != null) 
                          ? gridState.selectedZone!.zoneId 
                          : 0;
                      _showCreateTripBottomSheet(context, zId);
                    },
                    icon: const Icon(Icons.add_road, color: Colors.white),
                    label: const Text("Create Trip", style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
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

      // Decode the PNG to raw RGBA pixels
      final ui.Codec codec = await ui.instantiateImageCodec(list);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      final ByteData? rawBytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      
      if (rawBytes != null) {
        final Uint8List rawPixels = rawBytes.buffer.asUint8List();
        
        // 2. Add style image with raw RGBA data and correct dimensions
        await mapboxMap?.style.addStyleImage(
          'zona-x-driver-car',
          1.0,
          MbxImage(width: image.width, height: image.height, data: rawPixels),
          false,
          [],
          [],
          null,
        );
      }

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

  void _showCreateTripBottomSheet(BuildContext context, int initialZoneId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<MapGridBloc>()),
            BlocProvider(create: (_) => TripBloc()),
          ],
          child: CreateTripBottomSheet(initialPickupZoneId: initialZoneId),
        );
      },
    );
  }

  void _showUnifiedZoneBottomSheet(BuildContext context, int zoneId, String zoneName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<MapGridBloc>()),
            BlocProvider.value(value: context.read<DriverDistributionBloc>()),
          ],
          child: BlocBuilder<MapGridBloc, MapGridState>(
            builder: (context, mapState) {
              return BlocBuilder<DriverDistributionBloc, DriverDistributionState>(
                builder: (context, driverState) {
                  ZoneInsightsModel? insights;
                  DriverDistributionModel? driverDistribution;
                  if (mapState is GridReady) {
                    insights = mapState.insights;
                  }
                  
                  if (driverState is DriverDistributionLoaded) {
                    try {
                      driverDistribution = driverState.distributions.firstWhere((d) => d.zoneId == zoneId);
                    } catch (_) {}
                  }

                  if (mapState is GridReady && mapState.isLoadingInsights) {
                    return Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E2A),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                    );
                  }

                  if (mapState is GridReady && mapState.insightsError != null) {
                    return Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E2A),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Center(
                        child: Text("Error: \${mapState.insightsError}", style: const TextStyle(color: Colors.redAccent)),
                      ),
                    );
                  }

                  return UnifiedZoneDetailsBottomSheet(
                    zoneName: zoneName,
                    zoneId: zoneId,
                    insights: insights,
                    driverDistribution: driverDistribution,
                    comparison: ZoneComparisonModel(
                      totalRevenue: 2500.50,
                      expectedRevenue6H: 3100.00,
                      stockoutProbability: 0.15,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
