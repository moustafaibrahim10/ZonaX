import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

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

  static void _addInterceptors() {
    // Auth Interceptor for adding tokens
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: Add token dynamically here when Auth service is integrated
          // options.headers['Authorization'] = 'Bearer $token';
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
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
