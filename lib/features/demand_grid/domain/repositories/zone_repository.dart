import '../../data/models/zone_model.dart';
import '../../data/models/zone_heatmap_model.dart';
import '../../data/models/zone_insights_model.dart';
import '../../data/models/top_demand_zone_model.dart';
import '../../data/models/recommended_zone_model.dart';
import '../../data/models/peak_hour_model.dart';
import '../../data/models/driver_distribution_model.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class ZoneRepository {
  /// Fetches the real static zones from the backend.
  Future<Either<Failure, List<ZoneModel>>> getZones();

  /// Fetches the predictive heatmap data.
  Future<Either<Failure, List<ZoneHeatmapModel>>> getZonesHeatmap();

  Future<Either<Failure, ZoneInsightsModel>> getZoneInsights(int zoneId);

  Future<Either<Failure, List<TopDemandZoneModel>>> getTopDemandZones();

  Future<Either<Failure, List<RecommendedZoneModel>>> getRecommendedZones();

  Future<Either<Failure, List<PeakHourModel>>> getPeakHours();

  Future<Either<Failure, List<DriverDistributionModel>>> getDriverDistribution();

  /// Exposes a stream of zone updates simulating live API demand data.
  /// Each update is a list of maps containing {"zoneId": int, "demandLevel": int}
  Stream<List<Map<String, dynamic>>> getLiveDemandUpdates();
}
