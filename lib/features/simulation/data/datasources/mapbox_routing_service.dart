import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapboxRoutingService {
  final Dio dio;

  MapboxRoutingService(this.dio);

  Future<List<Map<String, double>>> getRoute(
      double startLat, double startLng, double endLat, double endLng) async {
    try {
      final token = dotenv.env['MAPBOX_ACCESS_TOKEN'];
      if (token == null || token.isEmpty) {
        throw Exception("Mapbox token is missing");
      }

      final url =
          "https://api.mapbox.com/directions/v5/mapbox/driving-traffic/$startLng,$startLat;$endLng,$endLat?geometries=geojson&overview=full&access_token=$token";

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;

          List<Map<String, double>> routePoints = [];
          for (var coord in coordinates) {
            // Mapbox returns [longitude, latitude]
            routePoints.add({
              'lat': (coord[1] as num).toDouble(),
              'lng': (coord[0] as num).toDouble(),
            });
          }
          return routePoints;
        } else {
          throw Exception("No route found");
        }
      } else {
        throw Exception("Failed to fetch route: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching Mapbox route: $e");
    }
  }
}
