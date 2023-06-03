// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanDto _$PlanDtoFromJson(Map<String, dynamic> json) => PlanDto(
      apis: (json['apis'] as List<dynamic>?)
          ?.map((e) => ApiDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      name: json['name'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$PlanDtoToJson(PlanDto instance) => <String, dynamic>{
      'apis': instance.apis,
      'name': instance.name,
      'title': instance.title,
    };
