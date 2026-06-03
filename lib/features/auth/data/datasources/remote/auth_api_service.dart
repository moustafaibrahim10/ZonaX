import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:zona_x_16_4/core/network/models/base_response.dart';
import 'package:zona_x_16_4/core/network/api_constants.dart';
import 'package:zona_x_16_4/features/auth/data/models/requests/login_request.dart';
import 'package:zona_x_16_4/features/auth/data/models/requests/register_driver_request.dart';
import 'package:zona_x_16_4/features/auth/data/models/requests/verify_otp_request.dart';
import 'package:zona_x_16_4/features/auth/data/models/requests/reset_password_request.dart';
import 'package:zona_x_16_4/features/auth/data/models/responses/auth_response.dart';

part 'auth_api_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String? baseUrl}) = _AuthApiService;

  @POST("/auth/login")
  Future<BaseResponse<AuthResponse>> login(@Body() LoginRequest request);

  @POST("/auth/register/driver")
  Future<BaseResponse<AuthResponse>> registerDriver(
    @Body() RegisterDriverRequest request,
  );

  @POST("/auth/otp/send")
  Future<BaseResponse<dynamic>> sendOtp(@Body() Map<String, dynamic> body);

  @POST("/auth/otp/verify")
  Future<BaseResponse<dynamic>> verifyOtp(
    @Body() VerifyOtpRequest request,
  );

  @POST("/auth/password/reset")
  Future<BaseResponse<dynamic>> resetPassword(
    @Body() ResetPasswordRequest request,
  );

  @GET("/auth/profile/{phoneNumber}")
  Future<BaseResponse<AuthResponse>> getProfile(
    @Path("phoneNumber") String phoneNumber,
  );
}
