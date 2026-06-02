import 'package:json_annotation/json_annotation.dart';

part 'reset_password_request.g.dart';

@JsonSerializable()
class ResetPasswordRequest {
  final String resetToken;
  final String newPassword;

  ResetPasswordRequest({required this.resetToken, required this.newPassword});

  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}
