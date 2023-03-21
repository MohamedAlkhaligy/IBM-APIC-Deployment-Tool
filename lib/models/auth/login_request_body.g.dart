// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestBody _$LoginRequestBodyFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'client_id',
      'client_secret',
      'password',
      'realm',
      'username'
    ],
  );
  return LoginRequestBody(
    json['client_id'] as String,
    json['client_secret'] as String,
    json['password'] as String,
    json['realm'] as String,
    json['username'] as String,
    grantType: json['grant_type'] as String? ?? 'password',
  );
}

Map<String, dynamic> _$LoginRequestBodyToJson(LoginRequestBody instance) =>
    <String, dynamic>{
      'client_id': instance.clientID,
      'client_secret': instance.clientSecret,
      'grant_type': instance.grantType,
      'password': instance.password,
      'realm': instance.realm,
      'username': instance.username,
    };
