import 'package:json_annotation/json_annotation.dart';

part 'configured_gateway.g.dart';

@JsonSerializable()
class Configuration {
  @JsonKey(name: 'managed_by')
  final String? managedBy;

  @JsonKey(name: 'domain_name')
  final String? domainName;

  @JsonKey(name: 'gateway_version')
  final String? gatewayVersion;

  Configuration(
    this.managedBy,
    this.domainName,
    this.gatewayVersion,
  );

  factory Configuration.fromJson(Map<String, dynamic> json) =>
      _$ConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigurationToJson(this);
}

@JsonSerializable()
class SNIItem {
  @JsonKey(name: 'host')
  final String? host;

  @JsonKey(name: 'tls_server_profile_url')
  final String? tlsServerProfileURL;

  SNIItem(
    this.host,
    this.tlsServerProfileURL,
  );

  factory SNIItem.fromJson(Map<String, dynamic> json) =>
      _$SNIItemFromJson(json);

  Map<String, dynamic> toJson() => _$SNIItemToJson(this);
}

@JsonSerializable()
class ConfiguredGateway {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'api_version')
  final String? apiVersion;

  @JsonKey(name: 'id')
  final String? id;

  /// [name] should be lowercase
  @JsonKey(name: 'name', required: true)
  final String name;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'summary')
  final String? summary;

  @JsonKey(name: 'state')
  final String? state;

  @JsonKey(name: 'scope')
  final String? scope;

  @JsonKey(name: 'gateway_service_url')
  final String? gatewayServiceURL;

  @JsonKey(name: 'integration_url')
  final String? integrationURL;

  @JsonKey(name: 'gateway_service_type')
  final String? gatewayServiceType;

  @JsonKey(name: 'owned')
  final bool? owned;

  @JsonKey(name: 'configuration')
  final Configuration? configuration;

  @JsonKey(name: 'availability_zone_url')
  final String? availabilityZoneURL;

  @JsonKey(name: 'endpoint')
  final String? endpoint;

  @JsonKey(name: 'api_endpoint_base')
  final String? apiEndpointBase;

  @JsonKey(name: 'catalog_base')
  final String? catalogBase;

  @JsonKey(name: 'sni')
  final List<SNIItem>? sni;

  @JsonKey(name: 'overall_state')
  final String? overallState;

  @JsonKey(name: 'tls_client_profile_url')
  final String? tlsClientProfileURL;

  @JsonKey(name: 'webhook_url')
  final String? webhookURL;

  @JsonKey(name: 'catalog_webhook_url')
  final String? catalogWebhookURL;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'org_url')
  final String? orgURL;

  @JsonKey(name: 'catalog_url')
  final String? catalogURL;

  @JsonKey(name: 'url')
  final String? url;

  ConfiguredGateway(
    this.name, {
    this.type,
    this.apiVersion,
    this.id,
    this.title,
    this.summary,
    this.state,
    this.scope,
    this.gatewayServiceURL,
    this.integrationURL,
    this.gatewayServiceType,
    this.owned,
    this.configuration,
    this.availabilityZoneURL,
    this.endpoint,
    this.apiEndpointBase,
    this.catalogBase,
    this.sni,
    this.overallState,
    this.tlsClientProfileURL,
    this.webhookURL,
    this.catalogWebhookURL,
    this.createdAt,
    this.updatedAt,
    this.orgURL,
    this.catalogURL,
    this.url,
  });

  factory ConfiguredGateway.fromJson(Map<String, dynamic> json) =>
      _$ConfiguredGatewayFromJson(json);

  Map<String, dynamic> toJson() => _$ConfiguredGatewayToJson(this);
}
