//for static data
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/zone_model.dart';

abstract class MapDataSource {
  Future<List<ZoneModel>> getActiveZones();
}

class MapMockDataSourceImpl implements MapDataSource {
  @override
  Future<List<ZoneModel>> getActiveZones() async {
    // محاكاة تأخير الشبكة عشان تحس إن التطبيق حقيقي
    await Future.delayed(const Duration(seconds: 1));

    // قراءة الملف من الـ assets
    final String response = await rootBundle.loadString(
      'assets/mock/zones_mock.json',
    );
    final Map<String, dynamic> jsonResponse = json.decode(response);

    // تحويل الـ List اللي جوه مفتاح "data" لموديلات
    final List<dynamic> zonesJson = jsonResponse['data'];
    return zonesJson.map((json) => ZoneModel.fromJson(json)).toList();
  }
}
