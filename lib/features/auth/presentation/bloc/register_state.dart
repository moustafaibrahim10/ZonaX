import 'package:equatable/equatable.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  final int currentStep;
  final String firstName;
  final String lastName;
  final int age;
  final String phoneNumber;
  final String city;
  final String street;
  final String licenseNumber;
  final String plateNumber;
  final String password;
  final String confirmPassword;
  
  final RegisterStatus status;
  final String? errorMessage;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const RegisterState({
    this.currentStep = 0,
    this.firstName = '',
    this.lastName = '',
    this.age = 25,
    this.phoneNumber = '',
    this.city = '',
    this.street = '',
    this.licenseNumber = '',
    this.plateNumber = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  RegisterState copyWith({
    int? currentStep,
    String? firstName,
    String? lastName,
    int? age,
    String? phoneNumber,
    String? city,
    String? street,
    String? licenseNumber,
    String? plateNumber,
    String? password,
    String? confirmPassword,
    RegisterStatus? status,
    String? errorMessage,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      street: street ?? this.street,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }

  @override
  List<Object?> get props => [
        currentStep, firstName, lastName, age, phoneNumber, city, street,
        licenseNumber, plateNumber, password, confirmPassword, status,
        errorMessage, isPasswordVisible, isConfirmPasswordVisible,
      ];
}
