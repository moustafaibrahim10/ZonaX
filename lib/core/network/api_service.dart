import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:zona_x_16_4/core/network/api_constants.dart';
import 'package:zona_x_16_4/features/map_inteligence/data/models/zone_model.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ApiService {
	factory ApiService(Dio dio, {String? baseUrl}) = _ApiService;

	@GET(ApiConstants.zonesEndpoint)
	Future<List<ZoneModel>> getActiveZones({@Query('active') bool active = true});
}
