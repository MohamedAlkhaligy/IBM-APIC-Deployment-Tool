import 'package:json_annotation/json_annotation.dart';

import 'subscribe_dto.dart';
import 'view_dto.dart';

part 'visibility_dto.g.dart';

@JsonSerializable()
class VisibilityDto {
  final ViewDto view;
  final SubscribeDto subscribe;

  VisibilityDto({required this.view, required this.subscribe});

  factory VisibilityDto.fromJson(Map<String, dynamic> json) =>
      _$VisibilityDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VisibilityDtoToJson(this);
}
