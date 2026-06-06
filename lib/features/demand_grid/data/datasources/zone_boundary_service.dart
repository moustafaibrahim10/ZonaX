import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Parses Overpass API response in an isolate to avoid jank on the main thread.
/// Returns a Map of osmId -> GeoJSON geometry string.
/// Handles relations (with members), ways (with geometry array), and nodes.
Map<String, String> _parseOverpassInIsolate(Map<String, dynamic> data) {
  final results = <String, String>{};
  try {
    final elements = data['elements'] as List<dynamic>?;
    if (elements == null) return results;

    for (var element in elements) {
      final osmId = element['id'];
      final type = element['type'] as String?;

      List<List<double>> coordinates = [];

      if (type == 'way') {
        // Ways have a direct 'geometry' array of {lat, lon} points
        final geometry = element['geometry'] as List<dynamic>?;
        if (geometry != null) {
          for (var point in geometry) {
            coordinates.add([
              (point['lon'] as num).toDouble(),
              (point['lat'] as num).toDouble(),
            ]);
          }
        }
      } else if (type == 'relation') {
        // Relations have 'members' with ways that have geometry
        final members = element['members'] as List<dynamic>?;
        if (members == null) continue;

        // Collect outer way coordinates first
        for (var member in members) {
          if (member['type'] == 'way' &&
              member['role'] == 'outer' &&
              member['geometry'] != null) {
            final geometry = member['geometry'] as List<dynamic>;
            for (var point in geometry) {
              coordinates.add([
                (point['lon'] as num).toDouble(),
                (point['lat'] as num).toDouble(),
              ]);
            }
          }
        }

        // Fallback: if no 'outer' role, use all ways
        if (coordinates.isEmpty) {
          for (var member in members) {
            if (member['type'] == 'way' && member['geometry'] != null) {
              final geometry = member['geometry'] as List<dynamic>;
              for (var point in geometry) {
                coordinates.add([
                  (point['lon'] as num).toDouble(),
                  (point['lat'] as num).toDouble(),
                ]);
              }
            }
          }
        }
      } else if (type == 'node') {
        // Nodes are single points — create a tiny square around them
        final lat = (element['lat'] as num?)?.toDouble();
        final lon = (element['lon'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          const offset = 0.001;
          coordinates = [
            [lon - offset, lat + offset],
            [lon + offset, lat + offset],
            [lon + offset, lat - offset],
            [lon - offset, lat - offset],
            [lon - offset, lat + offset],
          ];
        }
      }

      if (coordinates.length >= 4) {
        // Close the polygon ring if necessary
        if (coordinates.first[0] != coordinates.last[0] ||
            coordinates.first[1] != coordinates.last[1]) {
          coordinates.add(coordinates.first);
        }

        final geoJson = {
          "type": "Polygon",
          "coordinates": [coordinates],
        };

        results[osmId.toString()] = jsonEncode(geoJson);
      }
    }
  } catch (e) {
    // Isolate can't use debugPrint
  }
  return results;
}

class ZoneBoundaryService {
  static const String _boxName = 'zone_boundaries';

  // Keep for DI compatibility
  final Dio dio;
  ZoneBoundaryService({required this.dio});

  Future<void> initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  /// Performs a bulk fetch of OSM boundaries using dart:io HttpClient
  /// to completely bypass Dio interceptors and default headers.
  Future<void> fetchAndCacheBoundaries(List<int> osmIds) async {
    await initHive();
    final box = Hive.box<String>(_boxName);

    // Filter: remove negative IDs (not valid for Overpass) and already cached
    final idsToFetch = osmIds
        .where((id) => id > 0 && !box.containsKey(id.toString()))
        .toList();

    if (idsToFetch.isEmpty) {
      debugPrint('[ZoneBoundaryService] All ${osmIds.length} zones already cached or filtered.');
      return;
    }

    debugPrint('[ZoneBoundaryService] Fetching ${idsToFetch.length} boundaries from Overpass...');

    final queryString = _buildOverpassQuery(idsToFetch);
    final body = 'data=${Uri.encodeComponent(queryString)}';

    // Exponential backoff retry logic
    const maxRetries = 3;
    int delayMs = 2000;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Use dart:io HttpClient directly — zero Dio interference
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 30);

        final request = await client.postUrl(
          Uri.parse('https://overpass-api.de/api/interpreter'),
        );

        // Set ONLY the headers Overpass needs, nothing else
        request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
        request.headers.set('Accept', '*/*');
        request.headers.set('User-Agent', 'ZonaX-App/1.0');
        request.write(body);

        final response = await request.close().timeout(const Duration(seconds: 60));

        if (response.statusCode == 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          final jsonData = jsonDecode(responseBody) as Map<String, dynamic>;

          // Debug: inspect what Overpass actually returned
          final elements = jsonData['elements'] as List<dynamic>?;
          debugPrint('[ZoneBoundaryService] Response keys: ${jsonData.keys.toList()}');
          debugPrint('[ZoneBoundaryService] Elements count: ${elements?.length ?? 0}');
          if (elements != null && elements.isNotEmpty) {
            final first = elements.first;
            debugPrint('[ZoneBoundaryService] First element keys: ${(first as Map).keys.toList()}');
            debugPrint('[ZoneBoundaryService] First element type: ${first['type']}');
            debugPrint('[ZoneBoundaryService] First element id: ${first['id']}');
            if (first['members'] != null) {
              final members = first['members'] as List;
              debugPrint('[ZoneBoundaryService] First element members count: ${members.length}');
              if (members.isNotEmpty) {
                debugPrint('[ZoneBoundaryService] First member: ${members.first}');
              }
            }
            if (first['bounds'] != null) {
              debugPrint('[ZoneBoundaryService] First element bounds: ${first['bounds']}');
            }
            if (first['geometry'] != null) {
              debugPrint('[ZoneBoundaryService] First element has geometry key directly');
            }
          }

          // Parse in an isolate to avoid jank
          final parsed = await compute(_parseOverpassInIsolate, jsonData);

          // Write to Hive cache
          for (final entry in parsed.entries) {
            box.put(entry.key, entry.value);
          }

          debugPrint('[ZoneBoundaryService] ✅ Cached ${parsed.length} boundaries successfully.');
          client.close();
          return; // Success
        } else {
          final errorBody = await response.transform(utf8.decoder).join();
          debugPrint('[ZoneBoundaryService] Attempt $attempt: HTTP ${response.statusCode} - $errorBody');
          client.close();
        }
      } catch (e) {
        debugPrint('[ZoneBoundaryService] Attempt $attempt failed: $e');
      }

      if (attempt < maxRetries) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
      }
    }

    debugPrint('[ZoneBoundaryService] All retries exhausted. Falling back to squares.');
  }

  /// Retrieves a cached GeoJSON boundary for a specific osmId.
  Future<Map<String, dynamic>?> getBoundaryGeoJson(int osmId) async {
    await initHive();
    final box = Hive.box<String>(_boxName);
    final cached = box.get(osmId.toString());

    if (cached != null) {
      try {
        return jsonDecode(cached) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  String _buildOverpassQuery(List<int> osmIds) {
    // Extra safety: filter out any non-positive IDs
    final validIds = osmIds.where((id) => id > 0).toList();
    final idsString = validIds.join(',');
    return '[out:json][timeout:60];(nwr(id:$idsString););out geom;';
  }
}
