import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:convert';
import '../bloc/map_grid_bloc.dart';
import '../bloc/map_grid_event.dart';
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
  State<DemandGridMapIntegration> createState() =>
      _DemandGridMapIntegrationState();
}

class _DemandGridMapIntegrationState extends State<DemandGridMapIntegration> {
  static const String sourceId = 'demand-grid-source';
  static const String layerId = 'demand-grid-layer';

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

      // 5. Apply any instant feature state lookup values if present
      if (state.demandLookUp.isNotEmpty) {
        _applyDemandUpdates(
          state.demandLookUp.entries
              .map((e) => {'zoneId': e.key, 'demandLevel': e.value})
              .toList(),
        );
      }

      // Auto-focus camera on the first feature
      final decoded = jsonDecode(state.geoJson);
      if (decoded['features'] != null && decoded['features'].isNotEmpty) {
        final geometry = decoded['features'][0]['geometry'];
        // Handle Polygon coordinates (usually nested in an array)
        final coords = geometry['type'] == 'Polygon' 
            ? geometry['coordinates'][0][0] 
            : geometry['coordinates'][0];
            
        await widget.mapboxMap.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(coords[0], coords[1])),
            zoom: 13.0,
          ),
          MapAnimationOptions(duration: 1500),
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

    // الحل: ابدأ بلون مش شفاف عشان الماب بوكس "يشوف" الطبقة ويرسمها
    await style.addLayer(
      FillLayer(
        id: layerId,
        sourceId: sourceId,
        fillColor: Colors.grey.toARGB32(), // Use integer representation instead of String hex
        fillOpacity: 0.7,
        fillOutlineColor: Colors.white.toARGB32(),
      ),
    );

    // الـ Expression ده هيلون المربعات فوراً فوق اللون الافتراضي
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
  }

  Future<void> _addSymbolLayer() async {
    final style = widget.mapboxMap.style;
    await style.addLayer(
      SymbolLayer(
        id: 'demand-grid-symbol-layer',
        sourceId: sourceId,
        textField: "{surgeMultiplierText}",
        textSize: 14.0,
        textColor: Colors.white.toARGB32(),
        textHaloColor: Colors.black.withValues(alpha: 0.8).toARGB32(),
        textHaloWidth: 1.0,
      ),
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

  @override
  Widget build(BuildContext context) {
    debugPrint("Building DemandGridMapIntegration widget tree...");
    return BlocConsumer<MapGridBloc, MapGridState>(
      listener: (context, state) {
        if (state is GridReady) {
          debugPrint(
            "Bloc State GridReady: GeoJSON length = ${state.geoJson.length}",
          );
          _refreshMapLayers(state);
        } else if (state is DemandUpdated) {
          _applyDemandUpdates(state.latestUpdates);
        }
      },
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
    );
  }

}
