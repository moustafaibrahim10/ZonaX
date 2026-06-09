class ZoneModel {
  final int zoneId;
  final String zoneName;
  final int osmId;
  final double centerLatitude;
  final double centerLongitude;

  ZoneModel({
    required this.zoneId,
    required this.zoneName,
    required this.osmId,
    required this.centerLatitude,
    required this.centerLongitude,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      zoneId: json['zoneId'] as int,
      zoneName: json['zoneName'] as String,
      osmId: json['osmId'] as int,
      centerLatitude: (json['centerLatitude'] as num).toDouble(),
      centerLongitude: (json['centerLongitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'zoneName': zoneName,
      'osmId': osmId,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
    };
  }
}
