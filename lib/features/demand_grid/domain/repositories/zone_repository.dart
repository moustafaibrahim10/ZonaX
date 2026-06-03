abstract class ZoneRepository {
  /// Exposes a stream of zone updates simulating live API demand data.
  /// Each update is a list of maps containing {"zoneId": int, "demandLevel": int}
  Stream<List<Map<String, dynamic>>> getLiveDemandUpdates();
}
