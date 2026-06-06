import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final response = await dio.get('https://zonax.runasp.net/swagger/v1/swagger.json');
    await File('swagger.json').writeAsString(response.data is String ? response.data : response.data.toString());
    print('Swagger downloaded.');
  } catch (e) {
    print('Error: $e');
  }
}
