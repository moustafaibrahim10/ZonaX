import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  final String phoneNumber;
  final String password;

  LoginRequest({required this.phoneNumber, required this.password});

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
