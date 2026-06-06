import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final response = await dio.get('https://zonax.runasp.net/api/v1/zones');
    print(response.data);
  } catch (e) {
    if (e is DioException) {
      print('DioError: ${e.response?.data}');
    } else {
      print(e);
    }
  }
}
