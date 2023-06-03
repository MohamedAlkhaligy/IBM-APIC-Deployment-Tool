// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_products_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListProductsResponseDto _$ListProductsResponseDtoFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['total_results', 'results'],
  );
  return ListProductsResponseDto(
    json['total_results'] as int,
    (json['results'] as List<dynamic>)
        .map((e) => ProductDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ListProductsResponseDtoToJson(
        ListProductsResponseDto instance) =>
    <String, dynamic>{
      'total_results': instance.totalResults,
      'results': instance.result,
    };
