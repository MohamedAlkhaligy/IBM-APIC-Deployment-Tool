// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewDto _$ViewDtoFromJson(Map<String, dynamic> json) => ViewDto(
      type: json['type'] as String,
      orgs:
          (json['orgs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      enabled: json['enabled'] as bool?,
    );

Map<String, dynamic> _$ViewDtoToJson(ViewDto instance) => <String, dynamic>{
      'type': instance.type,
      'orgs': instance.orgs,
      'tags': instance.tags,
      'enabled': instance.enabled,
    };
