import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:zona_x_16_4/core/network/api_constants.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_config.dart';
import 'package:zona_x_16_4/features/simulation/data/models/simulation_status.dart';

part 'simulation_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class SimulationService {
  factory SimulationService(Dio dio, {String? baseUrl}) = _SimulationService;

  @POST('/simulation/start')
  Future<dynamic> startSimulation(@Body() SimulationConfig config);

  @POST('/simulation/pause')
  Future<void> pauseSimulation();

  @POST('/simulation/resume')
  Future<void> resumeSimulation();

  @POST('/simulation/stop')
  Future<void> stopSimulation();

  @POST('/simulation/speed')
  Future<void> updateSpeed(@Body() Map<String, dynamic> body);

  @GET('/simulation/status')
  Future<SimulationStatus> getStatus();

  @GET('/simulation/playback')
  Future<dynamic> getPlayback();
}
