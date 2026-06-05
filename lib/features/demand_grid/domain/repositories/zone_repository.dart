import '../../data/models/zone_model.dart';
import '../../data/models/zone_heatmap_model.dart';
import '../../data/models/zone_insights_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ZoneRepository {
  /// Fetches the real static zones from the backend.
  Future<Either<Failure, List<ZoneModel>>> getZones();

  /// Fetches the predictive heatmap data.
  Future<Either<Failure, List<ZoneHeatmapModel>>> getZonesHeatmap();

  Future<Either<Failure, ZoneInsightsModel>> getZoneInsights(int zoneId);

  /// Exposes a stream of zone updates simulating live API demand data.
  /// Each update is a list of maps containing {"zoneId": int, "demandLevel": int}
  Stream<List<Map<String, dynamic>>> getLiveDemandUpdates();
}
