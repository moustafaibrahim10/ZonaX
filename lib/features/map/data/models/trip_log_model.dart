import 'package:hive/hive.dart';

class TripLogModel extends HiveObject {
  final double lat;
  final double lng;
  final DateTime timestamp;
  bool synced;

  TripLogModel({
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.synced = false,
  });
}

class TripLogModelAdapter extends TypeAdapter<TripLogModel> {
  @override
  final int typeId = 0;

  @override
  TripLogModel read(BinaryReader reader) {
    return TripLogModel(
      lat: reader.readDouble(),
      lng: reader.readDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      synced: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, TripLogModel obj) {
    writer.writeDouble(obj.lat);
    writer.writeDouble(obj.lng);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeBool(obj.synced);
  }
}
