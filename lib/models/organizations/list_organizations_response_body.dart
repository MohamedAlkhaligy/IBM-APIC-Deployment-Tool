import 'package:json_annotation/json_annotation.dart';

import './organization.dart';

part 'list_organizations_response_body.g.dart';

@JsonSerializable()
class ListOrganizationsResponseBody {
  @JsonKey(name: 'total_results', required: true)
  final int totalResults;

  @JsonKey(name: 'results', required: true)
  final List<Organization> result;

  ListOrganizationsResponseBody(this.totalResults, this.result);

  factory ListOrganizationsResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ListOrganizationsResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ListOrganizationsResponseBodyToJson(this);
}
