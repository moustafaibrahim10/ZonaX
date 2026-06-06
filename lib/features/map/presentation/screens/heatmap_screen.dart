import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:zona_x_16_4/core/utils/app_images.dart';
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
import 'package:zona_x_16_4/features/demand_grid/data/models/zone_heatmap_model.dart';
import 'package:zona_x_16_4/features/profile/domain/usecases/update_driver_status_usecase.dart';
import 'package:zona_x_16_4/features/profile/data/repositories/driver_profile_repository_impl.dart';
import 'package:zona_x_16_4/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';
import 'package:zona_x_16_4/features/demand_grid/data/datasources/zone_boundary_service.dart';
import 'package:zona_x_16_4/features/demand_grid/presentation/widgets/unified_zone_details_bottom_sheet.dart';
import 'package:zona_x_16_4/features/demand_grid/data/models/driver_distribution_model.dart';
import 'package:zona_x_16_4/features/voice_assistant/presentation/widgets/voice_assistant_button.dart';
import 'package:zona_x_16_4/features/voice_assistant/presentation/bloc/voice_cubit.dart';
import 'package:zona_x_16_4/features/voice_assistant/presentation/bloc/voice_state.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_bloc.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_state.dart';
import 'package:zona_x_16_4/features/simulation/presentation/widgets/simulation_sidebar.dart';
import 'package:zona_x_16_4/features/simulation/presentation/widgets/simulation_map_layer.dart';
import 'package:zona_x_16_4/features/simulation/data/datasources/mapbox_routing_service.dart';
import 'package:zona_x_16_4/injection_container.dart' as di;
import 'package:zona_x_16_4/features/trips/presentation/bloc/trip_state.dart';
import 'package:zona_x_16_4/features/trips/presentation/bloc/trip_event.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeatmapScreen extends StatefulWidget {
  const HeatmapScreen({super.key});

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  MapboxMap? mapboxMap;
  late final UpdateDriverStatusUseCase _updateStatusUseCase;
  PointAnnotationManager? pointAnnotationManager;
  CircleAnnotationManager? circleAnnotationManager;
  PolygonAnnotationManager? polygonAnnotationManager;
  PolylineAnnotationManager? polylineAnnotationManager;
  PointAnnotation? carPointAnnotation;
  AnimationController? _carAnimationController;
  Animation<double>? _latAnimation;
  Animation<double>? _lngAnimation;
  Animation<double>? _bearingAnimation;
  PolylineAnnotation? routePolyline;
  bool isStyleLoaded = false;
  Uint8List? carIconBytes;

  int _currentDriverZoneId = 1;
  double _lastLat = 30.0444;
  double _lastLng = 31.2357;
  bool _isTrackingCar = true; // Default starting zone
  bool _isSelectingDropoff = false;
  int? _pendingDropoffZoneId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _updateStatusUseCase = UpdateDriverStatusUseCase(
      DriverProfileRepositoryImpl(
        ProfileRemoteDataSourceImpl(),
      ),
    );
    
    // Load last location
    _loadLastLocation();
    
    // Initial status update
    _sendStatusUpdate("Available");
  }

  Future<void> _loadLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _currentDriverZoneId = prefs.getInt('last_zone_id') ?? 1;
          _lastLat = prefs.getDouble('last_lat') ?? 30.0444;
          _lastLng = prefs.getDouble('last_lng') ?? 31.2357;
        });
      }
    } catch (e) {
      debugPrint("Error loading last location: $e");
    }
  }

  @override
  void dispose() {
    _carAnimationController?.dispose();
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
          BlocProvider(
            create: (context) => di.sl<SimulationBloc>(),
          ),
          BlocProvider(
            create: (context) => di.sl<TripBloc>(),
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
                      zoom: 15.5,
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
                                if (_isSelectingDropoff) {
                                  setState(() { _isSelectingDropoff = false; });
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  _showCreateTripBottomSheet(context, _currentDriverZoneId, initialDropoffZoneId: zoneId);
                                  return;
                                }
                                context.read<MapGridBloc>().add(FetchZoneInsights(zoneId: zoneId));
                                _showUnifiedZoneBottomSheet(context, zoneId, zoneName);
                              } else if (props.containsKey('demandPrediction') && props.containsKey('percentageOfTotalPredicted')) {
                                // It's a top-demand feature
                                final zoneId = props['zoneId'] as int;
                                final zoneName = props['zoneName']?.toString() ?? 'Hotspot';
                                if (!mounted) return;
                                if (_isSelectingDropoff) {
                                  setState(() { _isSelectingDropoff = false; });
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  _showCreateTripBottomSheet(context, _currentDriverZoneId, initialDropoffZoneId: zoneId);
                                  return;
                                }
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
                                  if (_isSelectingDropoff) {
                                    setState(() { _isSelectingDropoff = false; });
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    _showCreateTripBottomSheet(context, _currentDriverZoneId, initialDropoffZoneId: zoneId);
                                    return;
                                  }
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
                        // Draw car initially at the last known location
                        _updateCarPosition(_lastLat, _lastLng);
                      }
                    },
            ),

            // 1.5. Demand Grid Layer
            if (mapboxMap != null && gridState is GridReady)
              DemandGridMapIntegration(
                mapboxMap: mapboxMap!,
                initialState: gridState,
              ),

            // 1.6 Simulation Real-time Visualization Layer
            if (mapboxMap != null)
              SimulationMapLayer(mapboxMap: mapboxMap!),

          // Bloc Listener for map updates and voice actions
          MultiBlocListener(
            listeners: [
              BlocListener<MapCubit, MapState>(
                listener: (context, state) {
                  if (state is MapCarMoving) {
                    _lastLat = state.lat;
                    _lastLng = state.lng;
                    _updateCarPosition(state.lat, state.lng, state.bearing);
                  } else if (state is MapFlyToLocation) {
                    mapboxMap?.flyTo(
                      CameraOptions(
                        center: Point(coordinates: Position(state.lng, state.lat)),
                        zoom: 14.0,
                      ),
                      MapAnimationOptions(duration: 1500),
                    );
                  } else if (state is MapSimulationCompleted) {
                    if (polylineAnnotationManager != null && routePolyline != null) {
                      polylineAnnotationManager!.delete(routePolyline!);
                      routePolyline = null;
                    }
                    
                    // ALWAYS update the driver's current zone and location when simulation finishes
                    setState(() {
                      if (_pendingDropoffZoneId != null) {
                        _currentDriverZoneId = _pendingDropoffZoneId!;
                        _pendingDropoffZoneId = null;
                      } else {
                        // We stopped manually or arrived during repositioning
                        // Find the nearest zone to our current location
                        final distState = context.read<DriverDistributionBloc>().state;
                        if (distState is DriverDistributionLoaded) {
                          double minDistance = double.infinity;
                          int nearestZoneId = _currentDriverZoneId;
                          for (final dist in distState.distributions) {
                            final distance = math.sqrt(
                                math.pow(dist.centerLatitude - _lastLat, 2) + 
                                math.pow(dist.centerLongitude - _lastLng, 2)
                            );
                            if (distance < minDistance) {
                              minDistance = distance;
                              nearestZoneId = dist.zoneId;
                            }
                          }
                          _currentDriverZoneId = nearestZoneId;
                        }
                      }
                    });
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setInt('last_zone_id', _currentDriverZoneId);
                      prefs.setDouble('last_lat', _lastLat);
                      prefs.setDouble('last_lng', _lastLng);
                    });

                    final tripState = context.read<TripBloc>().state;
                    if (tripState is TripStarted) {
                      context.read<TripBloc>().add(EndTripRequested(tripState.tripId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trip ended successfully!'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Target zone reached successfully!'), backgroundColor: Colors.blue),
                      );
                    }
                  } else if (state is MapConnectivityChanged) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    if (!state.isConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.wifi_off, color: Colors.white),
                              SizedBox(width: 8),
                              Text('You are now in Offline Mode'),
                            ],
                          ),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(days: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.wifi, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Connection restored! Data synced.'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
              BlocListener<VoiceCubit, VoiceState>(
                listener: (context, state) {
                  if (state is VoiceActionTriggered && state.action == 'find_best_zone') {
                    _findAndRouteToBestZone(context);
                  } else if (state is VoiceActionTriggered && state.action == 'find_alternative_zone') {
                    _findAndRouteToAlternativeZone(context);
                  }
                },
              ),
            ],
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
                // Voice Visualizer at top
                Positioned(
                  top: 15.h,
                  left: 70.w, // offset for sidebar
                  right: 15.w,
                  child: const TopVoiceAssistantBar(),
                ),

                // Simulation Sidebar on the left
                Positioned(
                  top: 15.h,
                  left: 10.w,
                  child: const SimulationSidebar(),
                ),

                // Tracking toggle FAB
                Positioned(
                  bottom: 20.h,
                  right: 15.w,
                  child: FloatingActionButton(
                    heroTag: "tracking_fab",
                    backgroundColor: _isTrackingCar ? Colors.blueAccent : const Color(0xFF1E1E2A),
                    onPressed: () {
                      setState(() {
                        _isTrackingCar = !_isTrackingCar;
                      });
                      if (_isTrackingCar && carPointAnnotation != null) {
                        mapboxMap?.easeTo(
                          CameraOptions(center: carPointAnnotation!.geometry as Point),
                          MapAnimationOptions(duration: 500),
                        );
                      }
                    },
                    child: Icon(
                      _isTrackingCar ? Icons.my_location : Icons.location_searching,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Bottom Zone Info + Create Trip
                Positioned(
                  bottom: 15.h,
                  left: 15.w,
                  right: 15.w,
                  child: _buildMinimalBottomBar(),
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

  Widget _buildMinimalBottomBar() {
    return BlocBuilder<MapGridBloc, MapGridState>(
      builder: (context, gridState) {
        String zoneName = "Tap a zone";
        int zoneId = 0;
        String? demandTag;

        if (gridState is GridReady && gridState.selectedZone != null) {
          final zone = gridState.selectedZone!;
          zoneName = zone.zoneName;
          zoneId = zone.zoneId;
          demandTag = zone.demandLevel;
        }

        // Optional: show simulation time from SimulationBloc
        return BlocBuilder<SimulationBloc, SimulationState>(
          builder: (context, simState) {
            String? simTime;
            if (simState is SimulationRunning) {
              final raw = simState.status.currentTime;
              if (raw.contains('T')) {
                simTime = raw.split('T').last.replaceAll('Z', '');
                if (simTime.length > 5) simTime = simTime.substring(0, 5);
              }
            }

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1D2E), Color(0xFF252840)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Zone info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    zoneName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (demandTag != null) ...[
                                  SizedBox(width: 8.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: _demandTagColor(demandTag),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      demandTag,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (simTime != null)
                              Text(
                                'Sim Time: $simTime',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11.sp,
                                ),
                              ),
                          ],
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Create Trip FAB-style button
                      BlocBuilder<TripBloc, TripState>(
                        builder: (context, tripState) {
                          final isTripActive = tripState is TripStarted;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isTripActive ? null : () => _showCreateTripBottomSheet(context, zoneId),
                              borderRadius: BorderRadius.circular(14.r),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isTripActive 
                                      ? [Colors.green, Colors.green.shade700]
                                      : [const Color(0xFF2196F3), const Color(0xFF1565C0)],
                                  ),
                                  borderRadius: BorderRadius.circular(14.r),
                                  boxShadow: isTripActive ? null : [
                                    BoxShadow(
                                      color: const Color(0xFF2196F3).withValues(alpha: 0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isTripActive ? Icons.directions_car : Icons.add_road_rounded, 
                                        color: Colors.white, 
                                        size: 18.sp
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        isTripActive ? 'In Progress' : 'New Trip',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  BlocBuilder<MapCubit, MapState>(
                    builder: (context, mapState) {
                      final isSimulating = context.read<MapCubit>().isSimulating;
                      if (isSimulating) {
                        return Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.speed, color: Colors.white54, size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 2.h,
                                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                                      ),
                                      child: StatefulBuilder(
                                        builder: (context, setStateSlider) {
                                          final speed = context.read<MapCubit>().tripSpeed;
                                          return Slider(
                                            value: speed,
                                            min: 0.1,
                                            max: 5.0,
                                            divisions: 49,
                                            onChanged: (val) {
                                              setStateSlider(() {});
                                              context.read<MapCubit>().setTripSpeed(val);
                                            },
                                          );
                                        }
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${context.read<MapCubit>().tripSpeed.toStringAsFixed(1)}x',
                                    style: TextStyle(color: Colors.white54, fontSize: 10.sp),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent.withAlpha(50),
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(color: Colors.redAccent),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.stop_circle_outlined),
                                  label: const Text('Stop in this zone'),
                                  onPressed: () {
                                    context.read<MapCubit>().stopCarSimulation(emitCompletion: true);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _demandTagColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFFE53935);
      case 'ELEVATED':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  // --- Mapbox Logic ---

  Future<void> _initAnnotationManagers() async {
    polygonAnnotationManager = await mapboxMap?.annotations.createPolygonAnnotationManager();
    pointAnnotationManager = await mapboxMap?.annotations.createPointAnnotationManager();
    circleAnnotationManager = await mapboxMap?.annotations.createCircleAnnotationManager();
    polylineAnnotationManager = await mapboxMap?.annotations.createPolylineAnnotationManager();
  }



  void _updateCarPosition(double lat, double lng, [double bearing = 0.0]) async {
    final position = Position(lng, lat);

    if (carPointAnnotation == null) {
      if (carIconBytes == null) return;
      carPointAnnotation = await pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(coordinates: position),
          image: carIconBytes,
          iconSize: 0.08, // Reduced icon size
          iconRotate: bearing - 90.0,
        ),
      );
      
      _carAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600), // Match cubit interval
      )..addListener(() {
          if (carPointAnnotation != null && _latAnimation != null && _lngAnimation != null) {
            carPointAnnotation?.geometry = Point(coordinates: Position(_lngAnimation!.value, _latAnimation!.value));
            if (_bearingAnimation != null) {
              carPointAnnotation?.iconRotate = _bearingAnimation!.value - 90.0;
            }
            pointAnnotationManager?.update(carPointAnnotation!);
          }
        });
    } else {
      final currentPos = carPointAnnotation!.geometry as Point;
      final startLat = (currentPos.coordinates as Position).lat.toDouble();
      final startLng = (currentPos.coordinates as Position).lng.toDouble();
      final startBearing = carPointAnnotation!.iconRotate! + 90.0;

      // Adjust animation duration based on current trip speed (base is 600ms)
      int durationMs = 600;
      if (mounted) {
         try { durationMs = (600 / context.read<MapCubit>().tripSpeed).toInt(); } catch(_) {}
      }
      _carAnimationController?.duration = Duration(milliseconds: durationMs);

      _latAnimation = Tween<double>(begin: startLat, end: lat).animate(_carAnimationController!);
      _lngAnimation = Tween<double>(begin: startLng, end: lng).animate(_carAnimationController!);
      
      // Calculate shortest rotation path
      double endBearing = bearing;
      double diff = (endBearing - startBearing) % 360;
      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;
      _bearingAnimation = Tween<double>(begin: startBearing, end: startBearing + diff).animate(_carAnimationController!);

      _carAnimationController?.forward(from: 0.0);
      
      if (_isTrackingCar) {
        mapboxMap?.easeTo(
          CameraOptions(center: Point(coordinates: Position(lng, lat))),
          MapAnimationOptions(duration: durationMs),
        );
      }
    }
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

  void _moveCarToZone(BuildContext context, int zoneId) {
    final distState = context.read<DriverDistributionBloc>().state;
    if (distState is DriverDistributionLoaded) {
      try {
        final dist = distState.distributions.firstWhere((d) => d.zoneId == zoneId);
        _updateCarPosition(dist.centerLatitude, dist.centerLongitude);
      } catch (_) {}
    }
  }

  void _showCreateTripBottomSheet(BuildContext context, int initialZoneId, {int? initialDropoffZoneId}) async {
    // Capture the blocs before any async gap or builder to avoid deactivated widget lookup
    final mapGridBloc = context.read<MapGridBloc>();
    final tripBloc = context.read<TripBloc>();
    
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: mapGridBloc),
            BlocProvider.value(value: tripBloc),
          ],
          child: CreateTripBottomSheet(
            initialPickupZoneId: initialZoneId,
            initialDropoffZoneId: initialDropoffZoneId,
          ),
        );
      },
    );

    if (result != null && mounted) {
      if (result == -1) {
        setState(() {
          _isSelectingDropoff = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tap on the map to select Dropoff Zone', style: TextStyle(color: Colors.white, fontSize: 16)),
            backgroundColor: Colors.blueAccent,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        _startMapboxRouteSimulation(context, initialZoneId, result);
      }
    }
  }

  void _startMapboxRouteSimulation(BuildContext context, int startZoneId, int endZoneId) async {
    _pendingDropoffZoneId = endZoneId;
    final distState = context.read<DriverDistributionBloc>().state;
    if (distState is! DriverDistributionLoaded) return;

    try {
      final endZone = distState.distributions.firstWhere((d) => d.zoneId == endZoneId);

      double startLat;
      double startLng;

      if (carPointAnnotation != null && carPointAnnotation!.geometry is Point) {
        final point = carPointAnnotation!.geometry as Point;
        startLat = (point.coordinates as Position).lat.toDouble();
        startLng = (point.coordinates as Position).lng.toDouble();
      } else {
        final startZone = distState.distributions.firstWhere((d) => d.zoneId == startZoneId);
        startLat = startZone.centerLatitude;
        startLng = startZone.centerLongitude;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calculating route...', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
      );

      final routingService = MapboxRoutingService(di.sl<Dio>());
      final routePoints = await routingService.getRoute(
        startLat, startLng,
        endZone.centerLatitude, endZone.centerLongitude,
      );

      // Draw polyline
      if (polylineAnnotationManager != null) {
        await polylineAnnotationManager!.deleteAll();
        final coordinates = routePoints.map((p) => Position(p['lng']!, p['lat']!)).toList();
        final geometry = LineString(coordinates: coordinates);
        routePolyline = await polylineAnnotationManager!.create(
          PolylineAnnotationOptions(
            geometry: geometry,
            lineColor: Colors.blueAccent.withValues(alpha: 0.1).value, // Extremely light shadow
            lineWidth: 5.0, // Thinner line
            lineOpacity: 0.1, // Reduced opacity so roads are visible
          ),
        );
      }

      // Start Simulation via MapCubit
      if (mounted) {
        context.read<MapCubit>().startCarSimulation(routePoints);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _findAndRouteToBestZone(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finding the most profitable zone...'), backgroundColor: Colors.blueAccent),
    );
    
    final repo = di.sl<ZoneRepository>();
    final result = await repo.getTopDemandZones();
    
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find best zone right now.'), backgroundColor: Colors.red),
          );
        }
      },
      (zones) {
        if (zones.isNotEmpty && mounted) {
          final bestZone = zones.first; // Usually ordered by demand
          
          context.read<MapGridBloc>().add(ZoneSelected(bestZone.zoneId));
          context.read<MapGridBloc>().add(FetchZoneInsights(zoneId: bestZone.zoneId));
          
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E2A),
                title: const Text('Navigate to best zone', style: TextStyle(color: Colors.white)),
                content: Text('The highest demand zone right now is ${bestZone.zoneName}. Do you want to navigate there?', style: const TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _startMapboxRouteSimulation(context, _currentDriverZoneId, bestZone.zoneId);
                    },
                    child: const Text('Start Navigation'),
                  ),
                ],
              ),
            );
          }
        }
      }
    );
  }

  void _findAndRouteToAlternativeZone(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Finding a quieter alternative zone...'), backgroundColor: Colors.blueAccent),
    );
    
    final repo = di.sl<ZoneRepository>();
    final result = await repo.getZonesHeatmap();
    
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sorry, cannot suggest an alternative zone right now.'), backgroundColor: Colors.red),
          );
        }
      },
      (heatmaps) {
        if (heatmaps.isNotEmpty && mounted) {
          // Sort by predictedTripCount ascending (lowest demand first)
          final sortedHeatmaps = List<ZoneHeatmapModel>.from(heatmaps)..sort((a, b) => a.predictedTripCount.compareTo(b.predictedTripCount));
          
          ZoneHeatmapModel? alternativeZone;
          try {
             alternativeZone = sortedHeatmaps.firstWhere((z) => z.zoneId != _currentDriverZoneId);
          } catch (_) {
             alternativeZone = sortedHeatmaps.first;
          }
          
          context.read<MapGridBloc>().add(ZoneSelected(alternativeZone.zoneId));
          context.read<MapGridBloc>().add(FetchZoneInsights(zoneId: alternativeZone.zoneId));
          
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E2A),
                title: const Text('اقتراح منطقة بديلة', style: TextStyle(color: Colors.white)),
                content: Text('المنطقة الأهدأ حالياً هي ${alternativeZone!.zoneName}. هل تريد الانتقال إليها للاستراحة أو تجنب الزحام؟', style: const TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _startMapboxRouteSimulation(context, _currentDriverZoneId, alternativeZone!.zoneId);
                    },
                    child: const Text('بدء التحرك'),
                  ),
                ],
              ),
            );
          }
        }
      }
    );
  }

  void _showUnifiedZoneBottomSheet(BuildContext context, int zoneId, String zoneName) {
    final mapGridBloc = context.read<MapGridBloc>();
    final driverDistBloc = context.read<DriverDistributionBloc>();
    final tripBloc = context.read<TripBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: mapGridBloc),
            BlocProvider.value(value: driverDistBloc),
            BlocProvider.value(value: tripBloc),
          ],
          child: BlocBuilder<MapGridBloc, MapGridState>(
            builder: (context, mapState) {
              return BlocBuilder<DriverDistributionBloc, DriverDistributionState>(
                builder: (context, driverState) {
                  ZoneInsightsModel? insights;
                  DriverDistributionModel? driverDistribution;
                  ZoneComparisonModel? comparison;
                  if (mapState is GridReady) {
                    insights = mapState.insights;
                    if (mapState.comparisons != null && mapState.comparisons!.isNotEmpty) {
                      try {
                        comparison = mapState.comparisons!.firstWhere((c) => c.zoneId == zoneId);
                      } catch (_) {
                        comparison = mapState.comparisons!.first; // Fallback if zoneId doesn't strictly match but we only fetched 1
                      }
                    }
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
                    comparison: comparison,
                    onCreateTripTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _isSelectingDropoff = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tap on the map to select Dropoff Zone', style: TextStyle(color: Colors.white, fontSize: 16)),
                          backgroundColor: Colors.blueAccent,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    },
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
