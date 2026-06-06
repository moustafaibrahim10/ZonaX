import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:convert';
import '../bloc/map_grid_bloc.dart';
import '../bloc/map_grid_event.dart';
import '../bloc/map_grid_state.dart';
import '../bloc/driver_distribution_bloc.dart';
import 'package:zona_x_16_4/features/demand_grid/data/models/zone_heatmap_model.dart';

class DemandGridMapIntegration extends StatefulWidget {
  final MapboxMap mapboxMap;
  final GridReady initialState;

  const DemandGridMapIntegration({
    super.key,
    required this.mapboxMap,
    required this.initialState,
  });

  @override
  State<DemandGridMapIntegration> createState() =>
      _DemandGridMapIntegrationState();
}

class _DemandGridMapIntegrationState extends State<DemandGridMapIntegration> {
  static const String sourceId = 'demand-grid-source';
  static const String layerId = 'demand-grid-layer';
  static const String driverSourceId = 'driver-distribution-source';
  static const String driverLayerId = 'driver-distribution-layer';
  static const String topDemandSourceId = 'top-demand-source';
  static const String topDemandLayerId = 'top-demand-layer';
  @override
  void initState() {
    super.initState();
    _refreshMapLayers(widget.initialState);
  }

  /// Safely injects or dynamically updates the GeoJSON source to prevent flickers
  Future<void> _refreshMapLayers(GridReady state) async {
    try {
      final style = widget.mapboxMap.style;

      final featureCount = jsonDecode(state.geoJson)['features']?.length ?? 0;
      debugPrint("Drawing $featureCount zones");

      if (await style.styleSourceExists(sourceId)) {
        // Update existing source dynamically for instant visibility
        await style.setStyleSourceProperty(sourceId, "data", state.geoJson);

        // Force re-render: Re-add layers if they somehow went missing
        if (!(await style.styleLayerExists(layerId))) {
          await _addFillLayer();
        }

        if (!(await style.styleLayerExists('demand-grid-symbol-layer'))) {
          await _addSymbolLayer();
        }
      } else {
        // 1. Initial Creation: Add GeoJsonSource
        await style.addSource(GeoJsonSource(id: sourceId, data: state.geoJson));

        await _addFillLayer();
        await _addSymbolLayer();
      }

      // Handle Top Demand GeoJSON
      if (state.topDemandGeoJson != null) {
        if (await style.styleSourceExists(topDemandSourceId)) {
          await style.setStyleSourceProperty(topDemandSourceId, "data", state.topDemandGeoJson!);
          if (!(await style.styleLayerExists(topDemandLayerId))) {
            await _addTopDemandLayer();
          }
        } else {
          await style.addSource(GeoJsonSource(id: topDemandSourceId, data: state.topDemandGeoJson!));
          await _addTopDemandLayer();
        }
      }

      // 5. Apply any instant feature state lookup values if present
      if (state.demandLookUp.isNotEmpty) {
        _applyDemandUpdates(
          state.demandLookUp.entries
              .map((e) => {'zoneId': e.key, 'demandLevel': e.value})
              .toList(),
        );
      }



      // Force the map canvas to refresh
      await widget.mapboxMap.triggerRepaint();
    } catch (e) {
      debugPrint("Error rendering demand grid: $e");
    }
  }
  Future<void> _addFillLayer() async {
    final style = widget.mapboxMap.style;

    // 1. Fill Layer
    await style.addLayer(
      FillLayer(
        id: layerId,
        sourceId: sourceId,
        fillColor: Colors.grey.toARGB32(), // Use integer representation instead of String hex
        fillOutlineColor: Colors.white.toARGB32(),
      ),
    );

    // Expression to color by demand level
    await style.setStyleLayerProperty(
      layerId,
      'fill-color',
      [
        'match',
        ['get', 'demandLevel'], 
        'CRITICAL', '#FF0000', 
        'Critical', '#FF0000', 
        'critical', '#FF0000', 
        'ELEVATED', '#FFA500', 
        'Elevated', '#FFA500', 
        'elevated', '#FFA500', 
        'NORMAL', '#00FF00', 
        'Normal', '#00FF00', 
        'normal', '#00FF00', 
        '#808080' // Default grey fallback
      ],
    );

    // Initial opacity state (0.05 for all)
    await style.setStyleLayerProperty(layerId, 'fill-opacity', 0.05);

    // 2. Line Layer (Highlight Outline)
    await style.addLayer(
      LineLayer(
        id: 'demand-grid-outline-layer',
        sourceId: sourceId,
        lineWidth: 2.0,
        lineColor: Colors.transparent.toARGB32(), // Invisible by default
      ),
    );
  }

  void _updateSelectedZoneHighlight(ZoneHeatmapModel? selectedZone) async {
    try {
      final style = widget.mapboxMap.style;
      if (await style.styleLayerExists('demand-grid-outline-layer')) {
        if (selectedZone != null) {
          // Focus Mode: Dim all other zones, keep selected zone at 0.5
          if (await style.styleLayerExists(layerId)) {
            await style.setStyleLayerProperty(
              layerId,
              'fill-opacity',
              [
                'case',
                ['==', ['get', 'zoneId'], selectedZone.zoneId],
                0.2, // Selected zone opacity
                0.02 // Unselected zones opacity
              ]
            );
          }

          // Highlight boundary
          await style.setStyleLayerProperty(
            'demand-grid-outline-layer',
            'line-color',
            [
              'case',
              ['==', ['get', 'zoneId'], selectedZone.zoneId],
              '#FFC107', // Highlight color for selected zone (Amber)
              'rgba(0,0,0,0)' // Invisible for others
            ]
          );
          await style.setStyleLayerProperty(
            'demand-grid-outline-layer',
            'line-width',
            [
              'case',
              ['==', ['get', 'zoneId'], selectedZone.zoneId],
              4.0, // Thicker stroke for selected
              0.0
            ]
          );
        } else {
          // Reset Focus Mode
          if (await style.styleLayerExists(layerId)) {
            await style.setStyleLayerProperty(layerId, 'fill-opacity', 0.05);
          }
          await style.setStyleLayerProperty(
            'demand-grid-outline-layer',
            'line-color',
            'rgba(0,0,0,0)'
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating highlight: \${e}");
    }
  }

  Future<void> _addSymbolLayer() async {
    final style = widget.mapboxMap.style;
    await style.addLayer(
      SymbolLayer(
        id: 'demand-grid-symbol-layer',
        sourceId: sourceId,
        textField: "", // Placeholder, will set via expression
        textSize: 14.0,
        textColor: Colors.white.toARGB32(),
        textHaloColor: Colors.black.withValues(alpha: 0.8).toARGB32(),
        textHaloWidth: 1.0,
        textAllowOverlap: false,
      ),
    );

    // Conditional Labels: Only show text for CRITICAL demand levels
    await style.setStyleLayerProperty(
      'demand-grid-symbol-layer',
      'text-field',
      [
        'case',
        ['==', ['upcase', ['get', 'demandLevel']], 'CRITICAL'],
        ['get', 'surgeMultiplierText'],
        '' // Empty string for non-critical
      ],
    );
  }

  Future<void> _addTopDemandLayer() async {
    final style = widget.mapboxMap.style;
    
    // Create a pulsating orange glow for top demand zones
    await style.addLayerAt(
      CircleLayer(
        id: '${topDemandLayerId}-glow',
        sourceId: topDemandSourceId,
        circleColor: Colors.deepOrangeAccent.toARGB32(),
        circleRadius: 24.0,
        circleOpacity: 0.4,
        circleBlur: 0.8,
      ),
      LayerPosition(above: 'demand-grid-symbol-layer')
    );

    await style.addLayerAt(
      CircleLayer(
        id: topDemandLayerId,
        sourceId: topDemandSourceId,
        circleColor: Colors.redAccent.toARGB32(),
        circleRadius: 8.0,
        circleStrokeWidth: 2.0,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
      LayerPosition(above: '${topDemandLayerId}-glow')
    );
  }

  /// Uses setFeatureState to instantly update grid zones without redrawing the whole layer
  void _applyDemandUpdates(List<Map<String, dynamic>> updates) {
    for (final update in updates) {
      final zoneId = update['zoneId'] as int;
      final demandLevel = update['demandLevel'] as int;

      widget.mapboxMap.setFeatureState(
        sourceId,
        null,
        zoneId.toString(),
        jsonEncode({'demand': demandLevel}),
      );
    }
  }

  Future<void> _refreshDriverDistribution(DriverDistributionLoaded state) async {
    try {
      final style = widget.mapboxMap.style;
      if (await style.styleSourceExists(driverSourceId)) {
        await style.setStyleSourceProperty(driverSourceId, "data", state.geoJson);
        if (!(await style.styleLayerExists(driverLayerId))) {
          await _addDriverDistributionLayer();
        }
      } else {
        await style.addSource(GeoJsonSource(id: driverSourceId, data: state.geoJson));
        await _addDriverDistributionLayer();
      }
    } catch (e) {
      debugPrint("Error rendering driver distribution: $e");
    }
  }

  Future<void> _addDriverDistributionLayer() async {
    final style = widget.mapboxMap.style;
    
    // Outer glowing layer
    await style.addLayer(
      CircleLayer(
        id: '${driverLayerId}-glow',
        sourceId: driverSourceId,
        circleColor: Colors.grey.toARGB32(), // Placeholder
        circleRadius: 18.0, // Larger radius for glow
        circleOpacity: 0.3,
        circleBlur: 0.8,
      ),
    );

    await style.setStyleLayerProperty(
      '${driverLayerId}-glow',
      'circle-color',
      ['get', 'color'],
    );

    // Inner solid layer
    await style.addLayer(
      CircleLayer(
        id: driverLayerId,
        sourceId: driverSourceId,
        circleColor: Colors.grey.toARGB32(), // Placeholder
        circleRadius: 6.0, // Solid center
        circleStrokeWidth: 1.5,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    );

    await style.setStyleLayerProperty(
      driverLayerId,
      'circle-color',
      ['get', 'color'],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building DemandGridMapIntegration widget tree...");
    return MultiBlocListener(
      listeners: [
        BlocListener<MapGridBloc, MapGridState>(
          listener: (context, state) {
            if (state is GridReady) {
              debugPrint("Bloc State GridReady: GeoJSON length = ${state.geoJson.length}");
              _refreshMapLayers(state);
              _updateSelectedZoneHighlight(state.selectedZone);
            } else if (state is DemandUpdated) {
              _applyDemandUpdates(state.latestUpdates);
            }
          },
        ),
        BlocListener<DriverDistributionBloc, DriverDistributionState>(
          listener: (context, state) {
            if (state is DriverDistributionLoaded) {
              _refreshDriverDistribution(state);
            }
          },
        ),
      ],
      child: BlocBuilder<MapGridBloc, MapGridState>(
        builder: (context, state) {
          if (state is GridReady && state.isRefreshing) {
          return Positioned(
            top: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Updating...",
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink(); // Headless when not refreshing
        },
      ),
    );
  }
}
