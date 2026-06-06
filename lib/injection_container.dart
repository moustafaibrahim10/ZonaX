import 'package:get_it/get_it.dart';
import 'package:zona_x_16_4/core/network/dio_factory.dart';
import 'package:zona_x_16_4/features/demand_grid/data/datasources/zone_remote_data_source.dart';
import 'package:zona_x_16_4/features/demand_grid/data/datasources/zone_boundary_service.dart';
import 'package:zona_x_16_4/features/demand_grid/data/repositories/zone_repository_impl.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core / Network
  // Since DioFactory provides a static method, we can just inject the Dio instance directly
  // or we can register the Dio instance.
  sl.registerLazySingleton(() => DioFactory.getDio());

  // Data Sources
  sl.registerLazySingleton<ZoneRemoteDataSource>(
    () => ZoneRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<ZoneBoundaryService>(
    () => ZoneBoundaryService(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ZoneRepository>(
    () => ZoneRepositoryImpl(remoteDataSource: sl(), dio: sl()),
  );
}
