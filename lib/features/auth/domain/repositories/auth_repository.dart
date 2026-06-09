import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/requests/login_request.dart';
import '../../data/models/requests/register_driver_request.dart';
import '../../data/models/requests/verify_otp_request.dart';
import '../../data/models/requests/reset_password_request.dart';
import '../../data/models/responses/auth_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(LoginRequest request);
  Future<Either<Failure, AuthResponse>> registerDriver(RegisterDriverRequest request);
  Future<Either<Failure, void>> sendOtp(String phoneNumber);
  Future<Either<Failure, dynamic>> verifyOtp(VerifyOtpRequest request);
  Future<Either<Failure, void>> resetPassword(ResetPasswordRequest request);
  Future<Either<Failure, AuthResponse>> getProfile(String phoneNumber);
}
