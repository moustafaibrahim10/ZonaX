import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9uYW1laWRlbnRpZmllciI6ImEzYzNmOGE5LTJmNjUtNGNhNS05NWFhLTVkNDY0NjkzZWQzYiIsImh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vd3MvMjAwOC8wNi9pZGVudGl0eS9jbGFpbXMvcm9sZSI6IkRyaXZlciIsIkZ1bGxOYW1lIjoibW8gbW8iLCJodHRwOi8vc2NoZW1hcy54bWxzb2FwLm9yZy93cy8yMDA1LzA1L2lkZW50aXR5L2NsYWltcy9tb2JpbGVwaG9uZSI6IisyMDEwMDgwMzE0NDAiLCJleHAiOjE3ODA4MTI2NTYsImlzcyI6Ik5ZQ1RheGlEYXRhIiwiYXVkIjoiTllDVGF4aURhdGEifQ.WE1rsOHpKQU9hFFobEMxXLvm2DJei4NM38-LsfjIxOk';
  
  dio.options.headers['Authorization'] = 'Bearer $token';
  dio.options.headers['Content-Type'] = 'application/json';
  dio.options.headers['Accept'] = 'application/json';

  for (int i = 31; i <= 300; i++) {
    try {
      final response = await dio.post(
        'https://zonax.runasp.net/api/v1/trips',
        data: {
          "pickupLocationId": i,
          "dropoffLocationId": i, // use same so it doesn't fail on dropoff
          "fareAmount": 20.0,
          "tipAmount": 30.0,
          "driverId": "a3c3f8a9-2f65-4ca5-95aa-5d464693ed3b"
        },
      );
      print('SUCCESS with Pickup ID: $i -> ${response.data}');
      break; 
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data?['message'] ?? '';
        if (!msg.contains('does not exist')) {
          print('Found ID $i but different error: ${e.response?.data}');
          break;
        }
      }
    }
  }
  print('Done testing 31 to 300.');
}
