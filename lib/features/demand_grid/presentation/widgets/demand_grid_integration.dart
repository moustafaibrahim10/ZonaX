import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:convert';
import '../bloc/map_grid_bloc.dart';
import '../bloc/map_grid_state.dart';

class DemandGridMapIntegration extends StatefulWidget {
  final MapboxMap mapboxMap;
  final GridReady initialState;

  const DemandGridMapIntegration({
    super.key,
    required this.mapboxMap,
    required this.initialState,
  });

  @override
  State<DemandGridMapIntegration> createState() => _DemandGridMapIntegrationState();
}

class _DemandGridMapIntegrationState extends State<DemandGridMapIntegration> {
  static const String sourceId = 'demand-grid-source';
  static const String layerId = 'demand-grid-layer';

  @override
  void initState() {
    super.initState();
    _renderAndAnimateGrid(widget.mapboxMap, widget.initialState);
  }

  /// Injects the 256-zone GeoJSON as a GeoJsonSource and adds a FillLayer
  Future<void> _renderAndAnimateGrid(MapboxMap mapboxMap, GridReady state) async {
    try {
      // 1. Add GeoJsonSource with the 16x16 grid data
      await mapboxMap.style.addSource(GeoJsonSource(
        id: sourceId,
        data: state.geoJson,
      ));

      // 2. Add FillLayer with data-driven styling for the 'demand' feature-state
      await mapboxMap.style.addLayer(FillLayer(
        id: layerId,
        sourceId: sourceId,
        fillOutlineColor: Colors.white.withValues(alpha: 0.5).toARGB32(), // Use integer for outline color
      ));

      // 3. Set the fill color expression using setStyleLayerProperty
      await mapboxMap.style.setStyleLayerProperty(layerId, 'fill-color', jsonEncode([
        'interpolate',
        ['linear'],
        ['get', 'static_demand'], 
        15, 'rgba(76, 175, 80, 0.55)',    // 15: Translucent Green
        55, 'rgba(255, 235, 59, 0.6)',    // 55: Translucent Yellow
        95, 'rgba(244, 67, 54, 0.65)'     // 95: Translucent Red
      ]));

      // 3. Apply any initial lookup values if present
      if (state.demandLookUp.isNotEmpty) {
        _applyDemandUpdates(state.demandLookUp.entries.map((e) => {
          'zoneId': e.key,
          'demandLevel': e.value,
        }).toList());
      }
    } catch (e) {
      debugPrint("Error rendering demand grid: $e");
    }
  }

  /// Uses setFeatureState to instantly update grid zones without redrawing the whole layer
  void _applyDemandUpdates(List<Map<String, dynamic>> updates) {
    for (final update in updates) {
      final zoneId = update['zoneId'] as int;
      final demandLevel = update['demandLevel'] as int;

      // Update specific feature state instantly
      widget.mapboxMap.setFeatureState(
        sourceId,
        null, // sourceLayerId is null for GeoJsonSource
        zoneId.toString(), // featureId must correspond to the 'id' field in the GeoJSON Features
        jsonEncode({'demand': demandLevel}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocListener to react to DemandUpdated state and update Mapbox via setFeatureState
    return BlocListener<MapGridBloc, MapGridState>(
      listener: (context, state) {
        if (state is DemandUpdated) {
          _applyDemandUpdates(state.latestUpdates);
        }
      },
      child: const SizedBox.shrink(), // Headless widget, just reacts to state
    );
  }
}
