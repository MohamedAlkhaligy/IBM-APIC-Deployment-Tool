// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configured_gateway.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Configuration _$ConfigurationFromJson(Map<String, dynamic> json) =>
    Configuration(
      json['managed_by'] as String?,
      json['domain_name'] as String?,
      json['gateway_version'] as String?,
    );

Map<String, dynamic> _$ConfigurationToJson(Configuration instance) =>
    <String, dynamic>{
      'managed_by': instance.managedBy,
      'domain_name': instance.domainName,
      'gateway_version': instance.gatewayVersion,
    };

SNIItem _$SNIItemFromJson(Map<String, dynamic> json) => SNIItem(
      json['host'] as String?,
      json['tls_server_profile_url'] as String?,
    );

Map<String, dynamic> _$SNIItemToJson(SNIItem instance) => <String, dynamic>{
      'host': instance.host,
      'tls_server_profile_url': instance.tlsServerProfileURL,
    };

ConfiguredGateway _$ConfiguredGatewayFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name'],
  );
  return ConfiguredGateway(
    json['name'] as String,
    type: json['type'] as String?,
    apiVersion: json['api_version'] as String?,
    id: json['id'] as String?,
    title: json['title'] as String?,
    summary: json['summary'] as String?,
    state: json['state'] as String?,
    scope: json['scope'] as String?,
    gatewayServiceURL: json['gateway_service_url'] as String?,
    integrationURL: json['integration_url'] as String?,
    gatewayServiceType: json['gateway_service_type'] as String?,
    owned: json['owned'] as bool?,
    configuration: json['configuration'] == null
        ? null
        : Configuration.fromJson(json['configuration'] as Map<String, dynamic>),
    availabilityZoneURL: json['availability_zone_url'] as String?,
    endpoint: json['endpoint'] as String?,
    apiEndpointBase: json['api_endpoint_base'] as String?,
    catalogBase: json['catalog_base'] as String?,
    sni: (json['sni'] as List<dynamic>?)
        ?.map((e) => SNIItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    overallState: json['overall_state'] as String?,
    tlsClientProfileURL: json['tls_client_profile_url'] as String?,
    webhookURL: json['webhook_url'] as String?,
    catalogWebhookURL: json['catalog_webhook_url'] as String?,
    createdAt: json['created_at'] as String?,
    updatedAt: json['updated_at'] as String?,
    orgURL: json['org_url'] as String?,
    catalogURL: json['catalog_url'] as String?,
    url: json['url'] as String?,
  );
}

Map<String, dynamic> _$ConfiguredGatewayToJson(ConfiguredGateway instance) =>
    <String, dynamic>{
      'type': instance.type,
      'api_version': instance.apiVersion,
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'summary': instance.summary,
      'state': instance.state,
      'scope': instance.scope,
      'gateway_service_url': instance.gatewayServiceURL,
      'integration_url': instance.integrationURL,
      'gateway_service_type': instance.gatewayServiceType,
      'owned': instance.owned,
      'configuration': instance.configuration,
      'availability_zone_url': instance.availabilityZoneURL,
      'endpoint': instance.endpoint,
      'api_endpoint_base': instance.apiEndpointBase,
      'catalog_base': instance.catalogBase,
      'sni': instance.sni,
      'overall_state': instance.overallState,
      'tls_client_profile_url': instance.tlsClientProfileURL,
      'webhook_url': instance.webhookURL,
      'catalog_webhook_url': instance.catalogWebhookURL,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'org_url': instance.orgURL,
      'catalog_url': instance.catalogURL,
      'url': instance.url,
    };
