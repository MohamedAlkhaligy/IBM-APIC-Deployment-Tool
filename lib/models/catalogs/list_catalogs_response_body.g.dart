// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_catalogs_response_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListCatalogsResponseBody _$ListCatalogsResponseBodyFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['total_results', 'results'],
  );
  return ListCatalogsResponseBody(
    json['total_results'] as int,
    (json['results'] as List<dynamic>)
        .map((e) => Catalog.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ListCatalogsResponseBodyToJson(
        ListCatalogsResponseBody instance) =>
    <String, dynamic>{
      'total_results': instance.totalResults,
      'results': instance.result,
    };
