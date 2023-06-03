import 'package:json_annotation/json_annotation.dart';

import '../../../common/visibility_dto.dart';
import 'api_dto.dart';
import 'plan_dto.dart';

part 'product_dto.g.dart';

@JsonSerializable()
class ProductDto {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'api_version')
  final String? apiVersion;

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'version')
  final String? version;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'state')
  final String? state;

  @JsonKey(name: 'scope')
  final String? scope;

  @JsonKey(name: 'gateway_types')
  List<String>? gatewayTypes;

  @JsonKey(name: 'gateway_service_urls')
  final List<String>? gatewayServiceUrls;

  @JsonKey(name: 'visibility')
  final VisibilityDto? visibility;

  @JsonKey(name: 'api_urls')
  final List<String>? apiUrls;

  @JsonKey(name: 'oauth_provider_urls')
  final List<String>? oauthProviderUrls;

  @JsonKey(name: 'billing_urls')
  final List<String>? billingUrls;

  @JsonKey(name: 'plans')
  final List<PlanDto>? plans;

  @JsonKey(name: 'apis')
  final List<ApiDto>? apis;

  @JsonKey(name: 'task_urls')
  final List<String>? taskUrls;

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

  ProductDto({
    this.name,
    this.type,
    this.apiVersion,
    this.id,
    this.version,
    this.title,
    this.state,
    this.scope,
    this.gatewayTypes,
    this.gatewayServiceUrls,
    this.visibility,
    this.apiUrls,
    this.oauthProviderUrls,
    this.billingUrls,
    this.plans,
    this.apis,
    this.taskUrls,
    this.createdAt,
    this.updatedAt,
    this.orgURL,
    this.catalogURL,
    this.url,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDtoToJson(this);
}
