import 'package:json_annotation/json_annotation.dart';

part 'global_policy_meta.g.dart';

@JsonSerializable()
class GlobalPolicyMeta {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'api_version')
  final String? apiVersion;

  @JsonKey(name: 'id')
  final String? id;

  /// [name] should be lowercase
  @JsonKey(name: 'name', required: true)
  final String name;

  @JsonKey(name: 'version')
  final String? version;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'scope')
  final String? scope;

  @JsonKey(name: 'user_registry_urls')
  final List<String>? userRegistryURLs;

  @JsonKey(name: 'tls_client_profile_urls')
  final List<String>? tlsClientProfileURLs;

  @JsonKey(name: 'policy_urls')
  final List<String>? policyURLs;

  @JsonKey(name: 'gateway_service_url')
  final String? gatewayServiceURL;

  @JsonKey(name: 'global_policy')
  final Map<String, dynamic>? globalPolicy;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'org_url')
  final String? orgURL;

  @JsonKey(name: 'catalog_url')
  final String? catalogURL;

  /// In case of prehook or posthook global policies
  @JsonKey(name: 'global_policy_url')
  final String? globalPolicyURL;

  @JsonKey(name: 'url')
  final String? url;

  GlobalPolicyMeta(
    this.name, {
    this.type,
    this.apiVersion,
    this.id,
    this.version,
    this.title,
    this.scope,
    this.userRegistryURLs,
    this.tlsClientProfileURLs,
    this.policyURLs,
    this.gatewayServiceURL,
    this.globalPolicy,
    this.createdAt,
    this.updatedAt,
    this.orgURL,
    this.catalogURL,
    this.globalPolicyURL,
    this.url,
  });

  factory GlobalPolicyMeta.fromJson(Map<String, dynamic> json) =>
      _$GlobalPolicyMetaFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalPolicyMetaToJson(this);
}
