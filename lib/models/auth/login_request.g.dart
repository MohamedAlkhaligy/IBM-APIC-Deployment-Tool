// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['headers', 'body'],
  );
  return LoginRequest(
    LoginRequestBody.fromJson(json['body'] as Map<String, dynamic>),
    HTTPHeaders.fromJson(json['headers'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'headers': instance.headers,
      'body': instance.body,
    };
