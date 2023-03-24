// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openapi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAPI _$OpenAPIFromJson(Map<String, dynamic> json) => OpenAPI(
      info: APIInfo.fromJson(json['info'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAPIToJson(OpenAPI instance) => <String, dynamic>{
      'info': instance.info,
    };

APIInfo _$APIInfoFromJson(Map<String, dynamic> json) => APIInfo(
      version: json['version'] as String,
      title: json['title'] as String?,
      name: json['x-ibm-name'] as String,
    );

Map<String, dynamic> _$APIInfoToJson(APIInfo instance) => <String, dynamic>{
      'version': instance.version,
      'title': instance.title,
      'x-ibm-name': instance.name,
    };
