import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;
  static String? _authToken;

  static Dio getDio() {
    Duration timeOut = const Duration(milliseconds: ApiConstants.apiTimeOut);

    if (_dio == null) {
      _dio = Dio();
      _dio!
        ..options.baseUrl = ApiConstants.baseUrl
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut;

      _addInterceptors();
    }
    return _dio!;
  }

  // Set authentication token (call this after login)
  static void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear authentication token (call this on logout)
  static void clearAuthToken() {
    _authToken = null;
  }

  static void _addInterceptors() {
    // Auth Interceptor for adding tokens
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add Bearer token if available
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          options.headers['Accept'] = 'application/json';
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 Unauthorized (token expired)
          if (error.response?.statusCode == 401) {
            clearAuthToken();
            // TODO: Redirect to login screen
          }
          return handler.next(error);
        },
      ),
    );

    // Logging Interceptor for debugging
    if (kDebugMode) {
      _dio?.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }
}
