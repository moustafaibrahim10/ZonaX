import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String? id;
  final bool? isSuccess;
  final String? token;
  final String? message;
  final String? role;
  final String? fullName;

  AuthResponse({
    this.id,
    this.isSuccess,
    this.token,
    this.message,
    this.role,
    this.fullName,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
