// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_adaptor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductAdaptor _$ProductAdaptorFromJson(Map<String, dynamic> json) =>
    ProductAdaptor(
      info: Info.fromJson(json['info'] as Map<String, dynamic>),
      gateways:
          (json['gateways'] as List<dynamic>).map((e) => e as String).toList(),
      plans: (json['plans'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, PlanDetails.fromJson(e as Map<String, dynamic>)),
      ),
      apis: (json['apis'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, ApiAdaptor.fromJson(e as Map<String, dynamic>)),
      ),
      visibility:
          VisibilityDto.fromJson(json['visibility'] as Map<String, dynamic>),
      productVersion: json['product'] as String,
    );

Map<String, dynamic> _$ProductAdaptorToJson(ProductAdaptor instance) =>
    <String, dynamic>{
      'info': instance.info,
      'gateways': instance.gateways,
      'plans': instance.plans,
      'apis': instance.apis,
      'visibility': instance.visibility,
      'product': instance.productVersion,
    };

ApiAdaptor _$ApiAdaptorFromJson(Map<String, dynamic> json) => ApiAdaptor(
      name: json['name'] as String,
    );

Map<String, dynamic> _$ApiAdaptorToJson(ApiAdaptor instance) =>
    <String, dynamic>{
      'name': instance.name,
    };
