import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_bloc.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_state.dart';

/// Headless widget that overlays simulation demand colours on top of the
/// existing demand-grid.  Uses its OWN FillLayer (`sim-overlay-layer`)
/// so it never conflicts with [DemandGridMapIntegration].
///
/// Survives widget rebuilds: does NOT remove the overlay in [dispose],
/// and always checks Mapbox directly for layer existence.
class SimulationMapLayer extends StatefulWidget {
  final MapboxMap mapboxMap;
  final String sourceId;

  const SimulationMapLayer({
    super.key,
    required this.mapboxMap,
    this.sourceId = 'demand-grid-source',
  });

  @override
  State<SimulationMapLayer> createState() => _SimulationMapLayerState();
}

class _SimulationMapLayerState extends State<SimulationMapLayer> {
  static const _overlayId = 'sim-overlay-layer';
  StreamSubscription? _sub;
  bool _transitionApplied = false;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _sub = context
        .read<SimulationBloc>()
        .stream
        .throttleTime(const Duration(seconds: 1))
        .listen((state) {
      if (state is SimulationRunning) {
        _applyTick(state);
      } else if (state is SimulationStopped ||
          state is SimulationInitial ||
          state is SimulationError) {
        _removeOverlay();
      }
    });
  }

  Future<void> _applyTick(SimulationRunning state) async {
    if (state.status.zones.isEmpty) return;

    try {
      final style = widget.mapboxMap.style;

      // Source must exist
      if (!(await style.styleSourceExists(widget.sourceId))) return;

      // Ensure overlay layer exists (survives widget rebuilds)
      if (!(await style.styleLayerExists(_overlayId))) {
        await style.addLayerAt(
          FillLayer(
            id: _overlayId,
            sourceId: widget.sourceId,
            fillOpacity: 0.20, // Match the enhanced base opacity
          ),
          LayerPosition(above: 'demand-grid-layer'),
        );
        _transitionApplied = false;
        debugPrint('SimulationMapLayer: overlay layer created');
        
        // Hide base layer to prevent colors mixing and getting muddy
        if (await style.styleLayerExists('demand-grid-layer')) {
          await style.setStyleLayerProperty('demand-grid-layer', 'fill-opacity', 0.0);
        }
      }

      // Set transition once per layer creation
      if (!_transitionApplied) {
        await style.setStyleLayerProperty(
          _overlayId,
          'fill-color-transition',
          {"duration": 800, "delay": 0},
        );
        _transitionApplied = true;
      }

      // Build data-driven colour expression matching the Feature 'zoneId' property
      final expr = <dynamic>['match', ['get', 'zoneId']];
      for (final z in state.status.zones) {
        expr.add(z.zoneId); // The zoneId in geojson properties is an integer
        expr.add(_color(z.demand));
      }
      expr.add('rgba(0,0,0,0)'); // transparent fallback

      await style.setStyleLayerProperty(_overlayId, 'fill-color', expr);
    } catch (e) {
      debugPrint('SimulationMapLayer error: $e');
    }
  }

  Future<void> _removeOverlay() async {
    try {
      final style = widget.mapboxMap.style;
      if (await style.styleLayerExists(_overlayId)) {
        await style.removeStyleLayer(_overlayId);
        _transitionApplied = false;
        debugPrint('SimulationMapLayer: overlay removed');
        
        // Restore base layer (to the enhanced 0.15 opacity)
        if (await style.styleLayerExists('demand-grid-layer')) {
          await style.setStyleLayerProperty('demand-grid-layer', 'fill-opacity', 0.15);
        }
      }
    } catch (e) {
      debugPrint('SimulationMapLayer remove error: $e');
    }
  }

  String _color(double d) {
    if (d >= 40) return 'rgba(220, 20, 60, 0.15)';  // Crimson
    if (d >= 25) return 'rgba(255, 69, 0, 0.12)';   // OrangeRed
    if (d >= 12) return 'rgba(255, 165, 0, 0.10)';  // Orange
    if (d >= 5)  return 'rgba(255, 215, 0, 0.08)';  // Gold
    return 'rgba(50, 205, 50, 0.05)';               // LimeGreen
  }

  @override
  void dispose() {
    // IMPORTANT: Do NOT remove the overlay here.
    // The parent BlocBuilder may rebuild this widget while the
    // simulation is still running.  The overlay stays until the
    // Bloc emits SimulationStopped.
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
