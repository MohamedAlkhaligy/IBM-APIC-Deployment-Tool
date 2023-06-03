import 'package:json_annotation/json_annotation.dart';

import 'api_dto.dart';

part 'plan_dto.g.dart';

@JsonSerializable()
class PlanDto {
  @JsonKey(name: 'apis')
  List<ApiDto>? apis;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'title')
  String? title;

  PlanDto({
    this.apis,
    this.name,
    this.title,
  });

  factory PlanDto.fromJson(Map<String, dynamic> json) =>
      _$PlanDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PlanDtoToJson(this);
}
