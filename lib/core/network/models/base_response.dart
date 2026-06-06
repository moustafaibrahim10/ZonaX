import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  @JsonKey(name: 'isSuccess')
  final bool isSuccess;

  @JsonKey(name: 'isFailure')
  final bool? isFailure;

  @JsonKey(name: 'message')
  final String? message;

  @JsonKey(name: 'errorCode')
  final String? errorCode;

  @JsonKey(name: 'data')
  final T? data;

  BaseResponse({
    required this.isSuccess,
    this.isFailure,
    this.message,
    this.errorCode,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$BaseResponseFromJson(json, fromJsonT);
}
