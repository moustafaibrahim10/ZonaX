// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element

part of 'register_driver_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterDriverRequest _$RegisterDriverRequestFromJson(
  Map<String, dynamic> json,
) => RegisterDriverRequest(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  password: json['password'] as String,
  age: (json['age'] as num).toInt(),
  city: json['city'] as String,
  street: json['street'] as String,
  licenseNumber: json['licenseNumber'] as String,
  plateNumber: json['plateNumber'] as String,
);

Map<String, dynamic> _$RegisterDriverRequestToJson(
  RegisterDriverRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phoneNumber': instance.phoneNumber,
  'password': instance.password,
  'age': instance.age,
  'city': instance.city,
  'street': instance.street,
  'licenseNumber': instance.licenseNumber,
  'plateNumber': instance.plateNumber,
};
