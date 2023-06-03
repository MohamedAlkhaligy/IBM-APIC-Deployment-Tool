import 'package:json_annotation/json_annotation.dart';

part 'view_dto.g.dart';

@JsonSerializable()
class ViewDto {
  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'orgs', defaultValue: [])
  final List<String>? orgs;

  @JsonKey(name: 'tags', defaultValue: [])
  final List<String>? tags;

  @JsonKey(name: 'enabled')
  final bool? enabled;

  ViewDto({
    required this.type,
    this.orgs,
    this.tags,
    this.enabled,
  });

  factory ViewDto.fromJson(Map<String, dynamic> json) =>
      _$ViewDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ViewDtoToJson(this);
}
