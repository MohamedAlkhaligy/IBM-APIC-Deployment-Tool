import 'package:json_annotation/json_annotation.dart';

import './global_policy_meta.dart';

part 'list_global_policies_response_body.g.dart';

@JsonSerializable()
class ListGlobalPoliciesResponseBody {
  @JsonKey(name: 'total_results', required: true)
  final int totalResults;

  @JsonKey(name: 'results', required: true)
  final List<GlobalPolicyMeta> result;

  ListGlobalPoliciesResponseBody(this.totalResults, this.result);

  factory ListGlobalPoliciesResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ListGlobalPoliciesResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ListGlobalPoliciesResponseBodyToJson(this);
}
