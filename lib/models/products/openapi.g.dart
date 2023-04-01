// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openapi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAPI _$OpenAPIFromJson(Map<String, dynamic> json) => OpenAPI(
      info: APIInfo.fromJson(json['info'] as Map<String, dynamic>),
      ibmConfiguration: IbmConfiguration.fromJson(
          json['x-ibm-configuration'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAPIToJson(OpenAPI instance) => <String, dynamic>{
      'info': instance.info,
      'x-ibm-configuration': instance.ibmConfiguration,
    };

APIInfo _$APIInfoFromJson(Map<String, dynamic> json) => APIInfo(
      version: json['version'] as String,
      title: json['title'] as String?,
      name: json['x-ibm-name'] as String,
    );

Map<String, dynamic> _$APIInfoToJson(APIInfo instance) => <String, dynamic>{
      'version': instance.version,
      'title': instance.title,
      'x-ibm-name': instance.name,
    };

IbmConfiguration _$IbmConfigurationFromJson(Map<String, dynamic> json) =>
    IbmConfiguration(
      assembly: APIAssembly.fromJson(json['assembly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IbmConfigurationToJson(IbmConfiguration instance) =>
    <String, dynamic>{
      'assembly': instance.assembly,
    };

APIAssembly _$APIAssemblyFromJson(Map<String, dynamic> json) => APIAssembly(
      executeList: json['execute'] as List<dynamic>?,
      catchList: json['catch'] as List<dynamic>?,
    );

Map<String, dynamic> _$APIAssemblyToJson(APIAssembly instance) =>
    <String, dynamic>{
      'execute': instance.executeList,
      'catch': instance.catchList,
    };
