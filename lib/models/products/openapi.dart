import 'package:json_annotation/json_annotation.dart';

part 'openapi.g.dart';

@JsonSerializable()
class OpenAPI {
  @JsonKey(name: 'info')
  final APIInfo info;

  OpenAPI({
    required this.info,
  });

  factory OpenAPI.fromJson(Map<String, dynamic> json) =>
      _$OpenAPIFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAPIToJson(this);
}

@JsonSerializable()
class APIInfo {
  @JsonKey(name: 'version')
  final String version;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'x-ibm-name')
  final String name;

  APIInfo({
    required this.version,
    required this.title,
    required this.name,
  });

  factory APIInfo.fromJson(Map<String, dynamic> json) =>
      _$APIInfoFromJson(json);
  Map<String, dynamic> toJson() => _$APIInfoToJson(this);
}
