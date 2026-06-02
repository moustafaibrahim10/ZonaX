import 'package:json_annotation/json_annotation.dart';

part 'register_driver_request.g.dart';

@JsonSerializable()
class RegisterDriverRequest {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String password;
  final int age;
  final String city;
  final String street;
  final String licenseNumber;
  final String plateNumber;

  RegisterDriverRequest({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
    required this.age,
    required this.city,
    required this.street,
    required this.licenseNumber,
    required this.plateNumber,
  });

  Map<String, dynamic> toJson() => _$RegisterDriverRequestToJson(this);
}
