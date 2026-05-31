import '../entities/zone_entity.dart';

abstract class MapRepository {
  Future<List<ZoneEntity>> getActiveZones();
}