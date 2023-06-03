// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => ProductDto(
      name: json['name'] as String?,
      type: json['type'] as String?,
      apiVersion: json['api_version'] as String?,
      id: json['id'] as String?,
      version: json['version'] as String?,
      title: json['title'] as String?,
      state: json['state'] as String?,
      scope: json['scope'] as String?,
      gatewayTypes: (json['gateway_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      gatewayServiceUrls: (json['gateway_service_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      visibility: json['visibility'] == null
          ? null
          : VisibilityDto.fromJson(json['visibility'] as Map<String, dynamic>),
      apiUrls: (json['api_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      oauthProviderUrls: (json['oauth_provider_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      billingUrls: (json['billing_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      plans: (json['plans'] as List<dynamic>?)
          ?.map((e) => PlanDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      apis: (json['apis'] as List<dynamic>?)
          ?.map((e) => ApiDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      taskUrls: (json['task_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      orgURL: json['org_url'] as String?,
      catalogURL: json['catalog_url'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$ProductDtoToJson(ProductDto instance) =>
    <String, dynamic>{
      'type': instance.type,
      'api_version': instance.apiVersion,
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'title': instance.title,
      'state': instance.state,
      'scope': instance.scope,
      'gateway_types': instance.gatewayTypes,
      'gateway_service_urls': instance.gatewayServiceUrls,
      'visibility': instance.visibility,
      'api_urls': instance.apiUrls,
      'oauth_provider_urls': instance.oauthProviderUrls,
      'billing_urls': instance.billingUrls,
      'plans': instance.plans,
      'apis': instance.apis,
      'task_urls': instance.taskUrls,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'org_url': instance.orgURL,
      'catalog_url': instance.catalogURL,
      'url': instance.url,
    };
