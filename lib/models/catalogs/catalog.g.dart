// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Catalog _$CatalogFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name'],
  );
  return Catalog(
    json['name'] as String,
    type: json['type'] as String?,
    apiVersion: json['api_version'] as String?,
    id: json['id'] as String?,
    ownerUrl: json['owner_url'] as String?,
    title: json['title'] as String?,
    summary: json['summary'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
    url: json['url'] as String?,
  );
}

Map<String, dynamic> _$CatalogToJson(Catalog instance) => <String, dynamic>{
      'type': instance.type,
      'api_version': instance.apiVersion,
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'summary': instance.summary,
      'owner_url': instance.ownerUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'url': instance.url,
    };
