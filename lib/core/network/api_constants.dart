abstract final class ApiConstants {
  static const String baseUrl = 'https://zonax.runasp.net/api/v1';

  static const String zonesEndpoint = '/zones';
  static const String zonesMetadataEndpoint = '/zones/metadata';
  static const String topDemandEndpoint = '/zones/top-demand';

  static const String authLoginEndpoint = '/auth/login';
  static const String authRegisterEndpoint = '/auth/register/driver';
  static const String authOtpSendEndpoint = '/auth/otp/send';
  static const String authOtpVerifyEndpoint = '/auth/otp/verify';
  static const String authPasswordResetEndpoint = '/auth/password/reset';
  static const String authProfileEndpoint = '/auth/profile';

  static const String tripsEndpoint = '/trips';

  // Timeout
  static const int apiTimeOut = 60000;
}
