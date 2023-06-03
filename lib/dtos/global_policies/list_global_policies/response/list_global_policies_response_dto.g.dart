// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_global_policies_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListGlobalPoliciesResponseDto _$ListGlobalPoliciesResponseDtoFromJson(
    Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['total_results', 'results'],
  );
  return ListGlobalPoliciesResponseDto(
    json['total_results'] as int,
    (json['results'] as List<dynamic>)
        .map((e) => GlobalPolicyMeta.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ListGlobalPoliciesResponseDtoToJson(
        ListGlobalPoliciesResponseDto instance) =>
    <String, dynamic>{
      'total_results': instance.totalResults,
      'results': instance.result,
    };
