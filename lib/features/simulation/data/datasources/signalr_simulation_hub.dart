import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_status.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_zone.dart';
import 'package:flutter/foundation.dart';

class SignalRSimulationHub {
  final String _url = 'wss://zonax.runasp.net/hubs/simulation';
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _statusController = StreamController<SimulationStatus>.broadcast();
  SimulationStatus _currentStatus = SimulationStatus(status: 'Stopped', currentTime: '', speedFactor: 1.0);
  bool _shouldReconnect = false;

  Stream<SimulationStatus> get statusStream => _statusController.stream;

  // SignalR message delimiter
  static const _recordSeparator = '\x1e';

  Future<void> connect() async {
    try {
      if (_channel != null) {
        await disconnect();
      }

      _channel = WebSocketChannel.connect(Uri.parse(_url));
      _shouldReconnect = true;
      
      // Send handshake
      final handshakeMsg = jsonEncode({
        "protocol": "json",
        "version": 1
      });
      _channel!.sink.add('$handshakeMsg$_recordSeparator');

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message.toString());
        },
        onError: (error) {
          debugPrint('SignalR Hub Error: $error');
          _attemptReconnect();
        },
        onDone: () {
          debugPrint('SignalR Hub Disconnected');
          _attemptReconnect();
        },
      );
    } catch (e) {
      debugPrint('Error connecting to SignalR Hub: $e');
    }
  }

  void _attemptReconnect() {
    if (!_shouldReconnect) return;
    debugPrint('SignalR: Attempting reconnect in 3 seconds...');
    Future.delayed(const Duration(seconds: 3), () {
      if (_shouldReconnect) connect();
    });
  }

  void _handleMessage(String payload) {
    // A single payload may contain multiple messages separated by \x1e
    final messages = payload.split(_recordSeparator);
    
    for (final message in messages) {
      if (message.isEmpty) continue;
      
      try {
        final Map<String, dynamic> data = jsonDecode(message);
        debugPrint('SignalR Data: $data');
        
        // SignalR sends an empty `{}` message after successful handshake
        if (data.isEmpty) continue;

        // Check if it's a hub invocation message (type 1)
        if (data['type'] == 1) {
          final target = data['target']?.toString().toLowerCase();
          if (target == 'simulationstatus' || target == 'receivesimulationstatus' || target == 'updatesimulationstatus') {
            final args = data['arguments'] as List?;
            if (args != null && args.isNotEmpty) {
              final statusData = args.first as Map<String, dynamic>;
              final partial = SimulationStatus.fromJson(statusData);
              _currentStatus = _currentStatus.copyWith(
                status: partial.status,
                currentTime: partial.currentTime,
                speedFactor: partial.speedFactor,
              );
              _statusController.add(_currentStatus);
            }
          } else if (target == 'simulationtick' || target == 'receivesimulationtick' || target == 'updatesimulationtick') {
            final args = data['arguments'] as List?;
            if (args != null && args.isNotEmpty) {
              final tickData = args.first as Map<String, dynamic>;
              // Parse zones from the tick data
              final zonesList = (tickData['zones'] as List<dynamic>?)
                  ?.map<SimulationZone>((e) => SimulationZone.fromJson(e as Map<String, dynamic>))
                  .toList() ?? <SimulationZone>[];
              
              _currentStatus = _currentStatus.copyWith(
                status: '1', // If we're receiving ticks, we ARE running
                currentTime: tickData['simulatedTime']?.toString() ?? _currentStatus.currentTime,
                zones: zonesList,
              );
              _statusController.add(_currentStatus);
            }
          }
        }
        
        // Handle ping message (type 6) – MUST respond with pong to keep connection alive
        if (data['type'] == 6) {
          _sendPong();
        }
      } catch (e) {
        debugPrint('Error parsing SignalR message: $e');
      }
    }
  }

  void _sendPong() {
    try {
      final pong = jsonEncode({"type": 6});
      _channel?.sink.add('$pong$_recordSeparator');
    } catch (e) {
      debugPrint('Error sending pong: $e');
    }
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _statusController.close();
  }
}
