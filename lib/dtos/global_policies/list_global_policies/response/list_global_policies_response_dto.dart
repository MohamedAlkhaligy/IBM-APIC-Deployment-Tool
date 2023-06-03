import 'package:json_annotation/json_annotation.dart';

import '../../../../models/global_policies/global_policy_meta.dart';

part 'list_global_policies_response_dto.g.dart';

@JsonSerializable()
class ListGlobalPoliciesResponseDto {
  @JsonKey(name: 'total_results', required: true)
  final int totalResults;

  @JsonKey(name: 'results', required: true)
  final List<GlobalPolicyMeta> result;

  ListGlobalPoliciesResponseDto(this.totalResults, this.result);

  factory ListGlobalPoliciesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ListGlobalPoliciesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ListGlobalPoliciesResponseDtoToJson(this);
}
