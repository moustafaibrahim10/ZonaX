import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class SubmitStep1 extends RegisterEvent {
  final String firstName;
  final String lastName;
  final int age;
  const SubmitStep1({required this.firstName, required this.lastName, required this.age});
}

class SubmitStep2 extends RegisterEvent {
  final String phoneNumber;
  final String city;
  final String street;
  const SubmitStep2({required this.phoneNumber, required this.city, required this.street});
}

class SubmitStep3 extends RegisterEvent {
  final String licenseNumber;
  final String plateNumber;
  const SubmitStep3({required this.licenseNumber, required this.plateNumber});
}

class TogglePasswordVisibility extends RegisterEvent {
  final bool isConfirm;
  const TogglePasswordVisibility({this.isConfirm = false});
}

class PreviousStepTapped extends RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final String password;
  final String confirmPassword;
  const RegisterSubmitted({required this.password, required this.confirmPassword});
}
