// ⚠️ تأكد من هذا السطر، غير المسار حسب اسم مشروعك
import '../../domain/repositories/map_repository.dart'; 
import '../../domain/entities/zone_entity.dart';
import '../datasources/map_mock_data_source.dart';

// الآن لن يظهر الخطأ
class MapRepositoryImpl implements MapRepository {
  final MapDataSource dataSource;

  MapRepositoryImpl(this.dataSource);

  @override
  Future<List<ZoneEntity>> getActiveZones() async {
     final models = await dataSource.getActiveZones();
     return models; // بما أن Model يورث من Entity
  }
}