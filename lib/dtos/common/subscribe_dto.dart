import 'package:json_annotation/json_annotation.dart';

part 'subscribe_dto.g.dart';

@JsonSerializable()
class SubscribeDto {
  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'orgs', defaultValue: [])
  final List<String>? orgs;

  @JsonKey(name: 'tags', defaultValue: [])
  final List<String>? tags;

  @JsonKey(name: 'enabled')
  final bool? enabled;

  SubscribeDto({
    required this.type,
    this.orgs,
    this.tags,
    this.enabled,
  });

  factory SubscribeDto.fromJson(Map<String, dynamic> json) =>
      _$SubscribeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeDtoToJson(this);
}
