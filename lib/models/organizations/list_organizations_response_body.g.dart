// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_organizations_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListOrganizationsResponseBody _$ListOrganizationsResponseBodyFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['total_results', 'results'],
  );
  return ListOrganizationsResponseBody(
    json['total_results'] as int,
    (json['results'] as List<dynamic>)
        .map((e) => Organization.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ListOrganizationsResponseBodyToJson(
        ListOrganizationsResponseBody instance) =>
    <String, dynamic>{
      'total_results': instance.totalResults,
      'results': instance.result,
    };
