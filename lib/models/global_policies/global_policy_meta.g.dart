// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_policy_meta.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalPolicyMeta _$GlobalPolicyMetaFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name'],
  );
  return GlobalPolicyMeta(
    json['name'] as String,
    type: json['type'] as String?,
    apiVersion: json['api_version'] as String?,
    id: json['id'] as String?,
    version: json['version'] as String?,
    title: json['title'] as String?,
    scope: json['scope'] as String?,
    userRegistryURLs: (json['user_registry_urls'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    tlsClientProfileURLs: (json['tls_client_profile_urls'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    policyURLs: (json['policy_urls'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    gatewayServiceURL: json['gateway_service_url'] as String?,
    globalPolicy: json['global_policy'] as Map<String, dynamic>?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
    orgURL: json['org_url'] as String?,
    catalogURL: json['catalog_url'] as String?,
    globalPolicyURL: json['global_policy_url'] as String?,
    url: json['url'] as String?,
  );
}

Map<String, dynamic> _$GlobalPolicyMetaToJson(GlobalPolicyMeta instance) =>
    <String, dynamic>{
      'type': instance.type,
      'api_version': instance.apiVersion,
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'title': instance.title,
      'scope': instance.scope,
      'user_registry_urls': instance.userRegistryURLs,
      'tls_client_profile_urls': instance.tlsClientProfileURLs,
      'policy_urls': instance.policyURLs,
      'gateway_service_url': instance.gatewayServiceURL,
      'global_policy': instance.globalPolicy,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'org_url': instance.orgURL,
      'catalog_url': instance.catalogURL,
      'global_policy_url': instance.globalPolicyURL,
      'url': instance.url,
    };
