// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiDto _$ApiDtoFromJson(Map<String, dynamic> json) => ApiDto(
      id: json['id'] as String?,
      url: json['url'] as String?,
      name: json['name'] as String?,
      title: json['title'] as String?,
      version: json['version'] as String?,
    );

Map<String, dynamic> _$ApiDtoToJson(ApiDto instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'title': instance.title,
      'version': instance.version,
    };
