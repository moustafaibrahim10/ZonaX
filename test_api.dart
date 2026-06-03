import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://zonax.runasp.net/api/v1/drivers/analytics?driverId=559a7baf-4163-4353-852b-bf5091e20ffc');
  final response = await http.get(url);
  print(response.body);
}
