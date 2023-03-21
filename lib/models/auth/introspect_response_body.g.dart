// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'introspect_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntrospectResponseBody _$IntrospectResponseBodyFromJson(
        Map<String, dynamic> json) =>
    IntrospectResponseBody(
      json['type'] as String?,
      json['api_version'] as String?,
      json['name'] as String?,
      json['state'] as String?,
      json['identity_provider'] as String?,
      json['username'] as String?,
      json['email'] as String?,
      json['first_name'] as String?,
      json['last_name'] as String?,
      json['url'] as String?,
    );

Map<String, dynamic> _$IntrospectResponseBodyToJson(
        IntrospectResponseBody instance) =>
    <String, dynamic>{
      'type': instance.type,
      'api_version': instance.apiVersion,
      'name': instance.name,
      'state': instance.state,
      'identity_provider': instance.identityProvider,
      'username': instance.username,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'url': instance.url,
    };
