// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  id: json['id'] as String?,
  isSuccess: json['isSuccess'] as bool?,
  token: json['token'] as String?,
  message: json['message'] as String?,
  role: json['role'] as String?,
  fullName: json['fullName'] as String?,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isSuccess': instance.isSuccess,
      'token': instance.token,
      'message': instance.message,
      'role': instance.role,
      'fullName': instance.fullName,
    };
