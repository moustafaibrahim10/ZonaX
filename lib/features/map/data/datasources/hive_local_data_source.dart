import 'package:hive_flutter/hive_flutter.dart';
import 'package:zona_x_16_4/features/map/data/models/trip_log_model.dart';

abstract class LocalDataSource {
  Future<void> init();
  Future<void> saveTripLog(TripLogModel log);
  Future<List<TripLogModel>> getUnsyncedLogs();
  Future<void> markLogsAsSynced();
}

class HiveLocalDataSourceImpl implements LocalDataSource {
  static const String _boxName = 'trip_logs_box';

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TripLogModelAdapter());
    await Hive.openBox<TripLogModel>(_boxName);
  }

  @override
  Future<void> saveTripLog(TripLogModel log) async {
    final box = Hive.box<TripLogModel>(_boxName);
    await box.add(log);
  }

  @override
  Future<List<TripLogModel>> getUnsyncedLogs() async {
    final box = Hive.box<TripLogModel>(_boxName);
    return box.values.where((log) => !log.synced).toList();
  }

  @override
  Future<void> markLogsAsSynced() async {
    final box = Hive.box<TripLogModel>(_boxName);
    final unsynced = box.values.where((log) => !log.synced).toList();
    for (var log in unsynced) {
      log.synced = true;
      log.save();
    }
  }
}
