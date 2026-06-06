import 'package:get_it/get_it.dart';
import 'package:zona_x_16_4/core/network/dio_factory.dart';
import 'package:zona_x_16_4/features/demand_grid/data/datasources/zone_remote_data_source.dart';
import 'package:zona_x_16_4/features/demand_grid/data/datasources/zone_boundary_service.dart';
import 'package:zona_x_16_4/features/demand_grid/data/repositories/zone_repository_impl.dart';
import 'package:zona_x_16_4/features/demand_grid/domain/repositories/zone_repository.dart';
import 'package:zona_x_16_4/features/simulation/data/datasources/signalr_simulation_hub.dart';
import 'package:zona_x_16_4/features/simulation/data/datasources/simulation_service.dart';
import 'package:zona_x_16_4/features/simulation/domain/managers/simulation_manager.dart';
import 'package:zona_x_16_4/features/simulation/presentation/bloc/simulation_bloc.dart';

import 'package:zona_x_16_4/features/trips/data/datasources/trip_remote_data_source.dart';
import 'package:zona_x_16_4/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:zona_x_16_4/features/trips/domain/repositories/trip_repository.dart';
import 'package:zona_x_16_4/features/trips/presentation/bloc/trip_bloc.dart';

import 'package:zona_x_16_4/core/services/voice/gemini_service.dart';
import 'package:zona_x_16_4/core/services/voice/speech_service.dart';
import 'package:zona_x_16_4/core/services/voice/tts_service.dart';
import 'package:zona_x_16_4/features/voice_assistant/presentation/bloc/voice_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core / Network
  sl.registerLazySingleton(() => DioFactory.getDio());

  // Data Sources
  sl.registerLazySingleton<ZoneRemoteDataSource>(
    () => ZoneRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<ZoneBoundaryService>(
    () => ZoneBoundaryService(dio: sl()),
  );

  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ZoneRepository>(
    () => ZoneRepositoryImpl(remoteDataSource: sl(), dio: sl()),
  );

  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
  );

  // Simulation
  sl.registerLazySingleton<SimulationService>(
    () => SimulationService(sl()),
  );

  sl.registerLazySingleton<SignalRSimulationHub>(
    () => SignalRSimulationHub(),
  );

  sl.registerLazySingleton<SimulationManager>(
    () => SimulationManager(sl(), sl()),
  );

  // Blocs
  sl.registerFactory<SimulationBloc>(
    () => SimulationBloc(sl()),
  );

  sl.registerFactory<TripBloc>(
    () => TripBloc(tripRepository: sl()),
  );

  // Voice Assistant
  sl.registerLazySingleton<GeminiService>(() => GeminiService());
  sl.registerLazySingleton<SpeechService>(() => SpeechService());
  sl.registerLazySingleton<TtsService>(() => TtsService());

  sl.registerFactory<VoiceCubit>(
    () => VoiceCubit(
      geminiService: sl(),
      speechService: sl(),
      ttsService: sl(),
    ),
  );
}
