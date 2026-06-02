import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/requests/register_driver_request.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository _authRepository;

  RegisterBloc(this._authRepository) : super(const RegisterState()) {
    on<SubmitStep1>(_onSubmitStep1);
    on<SubmitStep2>(_onSubmitStep2);
    on<SubmitStep3>(_onSubmitStep3);
    on<TogglePasswordVisibility>(_onToggleVisibility);
    on<PreviousStepTapped>(_onPreviousStep);
    on<RegisterSubmitted>(_onSubmitted);
  }

  void _onSubmitStep1(SubmitStep1 event, Emitter<RegisterState> emit) {
    if (event.firstName.trim().isEmpty || event.lastName.trim().isEmpty) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: "Please fill in your name."));
      return;
    }
    emit(state.copyWith(
      firstName: event.firstName.trim(),
      lastName: event.lastName.trim(),
      age: event.age,
      currentStep: 1,
      errorMessage: '',
      status: RegisterStatus.initial,
    ));
  }

  void _onSubmitStep2(SubmitStep2 event, Emitter<RegisterState> emit) {
    if (event.phoneNumber.trim().isEmpty || event.city.trim().isEmpty || event.street.trim().isEmpty) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: "Please fill in all contact details."));
      return;
    }
    emit(state.copyWith(
      phoneNumber: event.phoneNumber.trim(),
      city: event.city.trim(),
      street: event.street.trim(),
      currentStep: 2,
      errorMessage: '',
      status: RegisterStatus.initial,
    ));
  }

  void _onSubmitStep3(SubmitStep3 event, Emitter<RegisterState> emit) {
    if (event.licenseNumber.trim().isEmpty || event.plateNumber.trim().isEmpty) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: "Please fill in vehicle details."));
      return;
    }
    emit(state.copyWith(
      licenseNumber: event.licenseNumber.trim(),
      plateNumber: event.plateNumber.trim(),
      currentStep: 3,
      errorMessage: '',
      status: RegisterStatus.initial,
    ));
  }

  void _onToggleVisibility(TogglePasswordVisibility event, Emitter<RegisterState> emit) {
    if (event.isConfirm) {
      emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
    } else {
      emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
    }
  }

  void _onPreviousStep(PreviousStepTapped event, Emitter<RegisterState> emit) {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1, errorMessage: '', status: RegisterStatus.initial));
    }
  }

  Future<void> _onSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    if (event.password.isEmpty || event.confirmPassword.isEmpty) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: "Passwords cannot be empty."));
      return;
    }
    if (event.password != event.confirmPassword) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: "Passwords do not match."));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading, errorMessage: ''));

    final request = RegisterDriverRequest(
      firstName: state.firstName,
      lastName: state.lastName,
      phoneNumber: '+20${state.phoneNumber}',
      password: event.password,
      age: state.age,
      city: state.city,
      street: state.street,
      licenseNumber: state.licenseNumber,
      plateNumber: state.plateNumber,
    );

    final result = await _authRepository.registerDriver(request);

    result.fold(
      (failure) => emit(state.copyWith(status: RegisterStatus.failure, errorMessage: failure.message)),
      (success) => emit(state.copyWith(status: RegisterStatus.success)),
    );
  }
}
