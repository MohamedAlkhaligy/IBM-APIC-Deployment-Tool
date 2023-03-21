import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

@JsonSerializable()
class Organization {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'org_type')
  final String? orgType;

  @JsonKey(name: 'api_version')
  final String? apiVersion;

  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'state')
  final String? state;

  @JsonKey(name: 'owner_url', required: true)
  final String ownerUrl;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'url')
  final String? url;

  Organization(
    this.ownerUrl, {
    this.type,
    this.orgType,
    this.apiVersion,
    this.id,
    this.name,
    this.title,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.url,
  });

  factory Organization.fromJson(Map<String, dynamic> json) =>
      _$OrganizationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationToJson(this);
}
