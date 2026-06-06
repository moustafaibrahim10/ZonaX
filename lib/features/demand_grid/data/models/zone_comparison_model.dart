class ZoneComparisonModel {
  final int zoneId;
  final double totalRevenue;
  final double expectedRevenue6H;
  final double stockoutProbability;

  ZoneComparisonModel({
    required this.zoneId,
    required this.totalRevenue,
    required this.expectedRevenue6H,
    required this.stockoutProbability,
  });

  factory ZoneComparisonModel.fromJson(Map<String, dynamic> json) {
    final predicted = json['predicted'] as Map<String, dynamic>?;
    return ZoneComparisonModel(
      zoneId: (json['zoneId'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      expectedRevenue6H: predicted != null ? ((predicted['expectedRevenue6H'] as num?)?.toDouble() ?? 0.0) : 0.0,
      stockoutProbability: predicted != null ? ((predicted['stockoutProbability'] as num?)?.toDouble() ?? 0.0) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'totalRevenue': totalRevenue,
      'predicted': {
        'expectedRevenue6H': expectedRevenue6H,
        'stockoutProbability': stockoutProbability,
      }
    };
  }
}
