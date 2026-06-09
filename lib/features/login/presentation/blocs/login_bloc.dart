import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zona_x_16_4/core/network/dio_factory.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/data/models/requests/login_request.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc(this._authRepository) : super(const LoginState()) {
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<SignInSubmitted>(_onSignInSubmitted);
    on<ForgotPasswordTapped>(_onForgotPasswordTapped);
    on<CreateAccountTapped>(_onCreateAccountTapped);
  }

  void _onPhoneNumberChanged(PhoneNumberChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      phoneNumber: event.phoneNumber,
      errorMessage: null, // intentionally not resetting completely here to match original logic but avoiding nulls usually. 
      // Wait, original logic set errorMessage to null? The generated copyWith needs to handle it.
      status: LoginStatus.initial,
    ));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.password,
      errorMessage: null,
      status: LoginStatus.initial,
    ));
  }

  void _onTogglePasswordVisibility(TogglePasswordVisibility event, Emitter<LoginState> emit) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> _onSignInSubmitted(SignInSubmitted event, Emitter<LoginState> emit) async {
    if (!state.isFormValid) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Please fill all fields'));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    final request = LoginRequest(
      phoneNumber: '+20${state.phoneNumber}',
      password: state.password,
    );

    final result = await _authRepository.login(request);

    result.fold(
      (failure) => emit(state.copyWith(status: LoginStatus.failure, errorMessage: failure.message)),
      (success) {
        // Set auth token in DioFactory for future API calls
        if (success.token != null && success.token!.isNotEmpty) {
          DioFactory.setAuthToken(success.token!);
        }
        emit(state.copyWith(status: LoginStatus.success));
      },
    );
  }

  void _onForgotPasswordTapped(ForgotPasswordTapped event, Emitter<LoginState> emit) {}

  void _onCreateAccountTapped(CreateAccountTapped event, Emitter<LoginState> emit) {}
}
