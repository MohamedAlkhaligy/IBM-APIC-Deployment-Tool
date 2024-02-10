import 'package:json_annotation/json_annotation.dart';

import '../../dtos/common/visibility_dto.dart';
import './product.dart';

part 'product_adaptor.g.dart';

@JsonSerializable()
class ProductAdaptor {
  @JsonKey(name: 'info')
  final Info info;

  @JsonKey(name: 'gateways')
  final List<String> gateways;

  @JsonKey(name: 'plans')
  final Map<String, PlanDetails> plans;

  @JsonKey(name: 'apis')
  final Map<String, ApiCloudReference> apis;

  @JsonKey(name: 'visibility')
  final VisibilityDto visibility;

  @JsonKey(name: 'product')
  final String productVersion;

  ProductAdaptor({
    required this.info,
    required this.gateways,
    required this.plans,
    required this.apis,
    required this.visibility,
    required this.productVersion,
  });

  ProductAdaptor.fromProduct(
      Product product, Map<String, ApiCloudReference> apiAdaptor)
      : info = product.info,
        gateways = product.gateways,
        plans = product.plans,
        apis = apiAdaptor,
        visibility = product.visibility,
        productVersion = product.productVersion;

  factory ProductAdaptor.fromJson(Map<String, dynamic> json) =>
      _$ProductAdaptorFromJson(json);

  Map<String, dynamic> toJson() => _$ProductAdaptorToJson(this);
}

@JsonSerializable()
class ApiCloudReference {
  @JsonKey(name: 'name')
  final String name;

  ApiCloudReference({required this.name});

  factory ApiCloudReference.fromJson(Map<String, dynamic> json) =>
      _$ApiCloudReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$ApiCloudReferenceToJson(this);
}
