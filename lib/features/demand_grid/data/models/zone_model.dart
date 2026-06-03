class ZoneModel {
  final int zoneId;
  final int demandLevel;

  ZoneModel({
    required this.zoneId,
    required this.demandLevel,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      zoneId: json['zoneId'] as int,
      demandLevel: json['demandLevel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'demandLevel': demandLevel,
    };
  }
}
