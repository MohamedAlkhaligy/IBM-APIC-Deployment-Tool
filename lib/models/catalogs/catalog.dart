import 'package:json_annotation/json_annotation.dart';

part 'catalog.g.dart';

@JsonSerializable()
class Catalog {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'api_version')
  final String? apiVersion;

  @JsonKey(name: 'id')
  final String? id;

  /// [name] should be lowercase
  @JsonKey(name: 'name', required: true)
  final String name;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'summary')
  final String? summary;

  @JsonKey(name: 'owner_url')
  final String? ownerUrl;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'url')
  final String? url;

  Catalog(
    this.name, {
    this.type,
    this.apiVersion,
    this.id,
    this.ownerUrl,
    this.title,
    this.summary,
    this.createdAt,
    this.updatedAt,
    this.url,
  });

  factory Catalog.fromJson(Map<String, dynamic> json) =>
      _$CatalogFromJson(json);

  Map<String, dynamic> toJson() => _$CatalogToJson(this);
}
