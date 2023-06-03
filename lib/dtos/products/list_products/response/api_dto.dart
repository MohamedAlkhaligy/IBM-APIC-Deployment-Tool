import 'package:json_annotation/json_annotation.dart';

part 'api_dto.g.dart';

@JsonSerializable()
class ApiDto {
  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "url")
  String? url;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "title")
  String? title;

  @JsonKey(name: "version")
  String? version;

  ApiDto({
    this.id,
    this.url,
    this.name,
    this.title,
    this.version,
  });

  factory ApiDto.fromJson(Map<String, dynamic> json) => _$ApiDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ApiDtoToJson(this);
}
