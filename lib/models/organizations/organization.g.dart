// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Organization _$OrganizationFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['owner_url'],
  );
  return Organization(
    json['owner_url'] as String,
    type: json['type'] as String?,
    orgType: json['org_type'] as String?,
    apiVersion: json['api_version'] as String?,
    id: json['id'] as String?,
    name: json['name'] as String?,
    title: json['title'] as String?,
    state: json['state'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
    url: json['url'] as String?,
  );
}

Map<String, dynamic> _$OrganizationToJson(Organization instance) =>
    <String, dynamic>{
      'type': instance.type,
      'org_type': instance.orgType,
      'api_version': instance.apiVersion,
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'state': instance.state,
      'owner_url': instance.ownerUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'url': instance.url,
    };
