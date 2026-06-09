import 'zone_comparison_model.dart';

class ZoneComparisonResponse {
  final List<ZoneComparisonModel> comparisonData;

  ZoneComparisonResponse({required this.comparisonData});

  factory ZoneComparisonResponse.fromJson(Map<String, dynamic> json) {
    final list = json['comparisonData'] as List<dynamic>? ?? [];
    return ZoneComparisonResponse(
      comparisonData: list.map((e) => ZoneComparisonModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
