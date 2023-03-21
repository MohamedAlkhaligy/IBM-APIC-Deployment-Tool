// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_configured_gateways_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListConfiguredGatewaysResponseBody _$ListConfiguredGatewaysResponseBodyFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['total_results', 'results'],
  );
  return ListConfiguredGatewaysResponseBody(
    json['total_results'] as int,
    (json['results'] as List<dynamic>)
        .map((e) => ConfiguredGateway.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ListConfiguredGatewaysResponseBodyToJson(
        ListConfiguredGatewaysResponseBody instance) =>
    <String, dynamic>{
      'total_results': instance.totalResults,
      'results': instance.result,
    };
