import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/zone_model.dart';
import '../models/zone_heatmap_model.dart';
import '../models/zone_insights_model.dart';
import '../models/top_demand_zone_model.dart';
import '../models/recommended_zone_model.dart';
import '../models/peak_hour_model.dart';
import '../models/driver_distribution_model.dart';
import '../models/zone_comparison_model.dart';
import '../models/zone_comparison_response.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/models/base_response.dart';

part 'zone_remote_data_source.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ZoneRemoteDataSource {
  factory ZoneRemoteDataSource(Dio dio, {String baseUrl}) = _ZoneRemoteDataSource;

  @GET('/zones')
  Future<BaseResponse<List<ZoneModel>>> getZones();

  @GET('/zones/heatmap')
  Future<BaseResponse<List<ZoneHeatmapModel>>> getZonesHeatmap();

  @GET('/zones/{id}/insights')
  Future<BaseResponse<ZoneInsightsModel>> getZoneInsights(@Path("id") int zoneId);

  @GET('/zones/top-demand')
  Future<BaseResponse<List<TopDemandZoneModel>>> getTopDemandZones();

  @GET('/zones/recommended')
  Future<BaseResponse<List<RecommendedZoneModel>>> getRecommendedZones();

  @GET('/zones/peak-hours')
  Future<BaseResponse<List<PeakHourModel>>> getPeakHours();

  @GET('/zones/driver-distribution')
  Future<BaseResponse<List<DriverDistributionModel>>> getDriverDistribution();

  @GET('/zones/compare')
  Future<BaseResponse<ZoneComparisonResponse>> compareZones(@Query("zoneIds") List<int> zoneIds);
}
