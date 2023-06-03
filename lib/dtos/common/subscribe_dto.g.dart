// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeDto _$SubscribeDtoFromJson(Map<String, dynamic> json) => SubscribeDto(
      type: json['type'] as String,
      orgs:
          (json['orgs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      enabled: json['enabled'] as bool?,
    );

Map<String, dynamic> _$SubscribeDtoToJson(SubscribeDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'orgs': instance.orgs,
      'tags': instance.tags,
      'enabled': instance.enabled,
    };
