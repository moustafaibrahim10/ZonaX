import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_api_service.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../models/requests/login_request.dart';
import '../models/requests/register_driver_request.dart';
import '../models/requests/verify_otp_request.dart';
import '../models/requests/reset_password_request.dart';
import '../models/responses/auth_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._apiService, this._localDataSource);

  String _extractErrorMessage(Object e) {
    String errorMessage = "An error occurred, please try again later";
    if (e is DioException) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('message') && data['message'] != null) {
            errorMessage = data['message'].toString();
          } else if (data.containsKey('error') && data['error'] != null) {
            errorMessage = data['error'].toString();
          } else if (data.containsKey('title') && data['title'] != null) {
            errorMessage = data['title'].toString(); // .NET validation errors
          } else {
            errorMessage = data.toString();
          }
        } else {
          errorMessage = data.toString();
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
    } else {
      errorMessage = e.toString();
    }
    return errorMessage;
  }

  @override
  Future<Either<Failure, AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _apiService.login(request);
      if (response.isSuccess && response.data != null) {
        final authData = response.data!;
        if (authData.token != null) {
          await _localDataSource.saveToken(authData.token!);
        }
        await _localDataSource.saveUserProfile(authData);
        return Right(authData);
      } else {
        return Left(ServerFailure(response.data?.message ?? "Login failed"));
      }
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> registerDriver(RegisterDriverRequest request) async {
    try {
      final response = await _apiService.registerDriver(request);
      if (response.isSuccess && response.data != null) {
        final authData = response.data!;
        if (authData.token != null) {
          await _localDataSource.saveToken(authData.token!);
        }
        await _localDataSource.saveUserProfile(authData);
        return Right(authData);
      } else {
        return Left(ServerFailure(response.data?.message ?? "Registration failed"));
      }
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> sendOtp(String phoneNumber) async {
    try {
      final response = await _apiService.sendOtp({"phoneNumber": phoneNumber});
      if (response.isSuccess) {
        return const Right(null);
      } else {
        return const Left(ServerFailure("Failed to send OTP"));
      }
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, dynamic>> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _apiService.verifyOtp(request);
      if (response.isSuccess && response.data != null) {
        return Right(response.data!);
      } else {
        return const Left(ServerFailure("Failed to verify OTP"));
      }
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(ResetPasswordRequest request) async {
    try {
      final response = await _apiService.resetPassword(request);
      if (response.isSuccess) {
        return const Right(null);
      } else {
        return const Left(ServerFailure("Failed to reset password"));
      }
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> getProfile(String phoneNumber) async {
    try {
      final response = await _apiService.getProfile(phoneNumber);
      if (response.isSuccess && response.data != null) {
        await _localDataSource.saveUserProfile(response.data!);
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.data?.message ?? "Failed to fetch profile"));
      }
    } catch (e) {
      return Left(ServerFailure(_extractErrorMessage(e)));
    }
  }
}
