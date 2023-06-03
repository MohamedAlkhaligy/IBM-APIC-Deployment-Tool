// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visibility_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisibilityDto _$VisibilityDtoFromJson(Map<String, dynamic> json) =>
    VisibilityDto(
      view: ViewDto.fromJson(json['view'] as Map<String, dynamic>),
      subscribe:
          SubscribeDto.fromJson(json['subscribe'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VisibilityDtoToJson(VisibilityDto instance) =>
    <String, dynamic>{
      'view': instance.view,
      'subscribe': instance.subscribe,
    };
