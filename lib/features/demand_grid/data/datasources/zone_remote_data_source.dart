import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/zone_model.dart';
import '../models/zone_heatmap_model.dart';
import '../models/zone_insights_model.dart';
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
}
