import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';

part 'openapi.g.dart';

@JsonSerializable()
class OpenApi {
  static Future<OpenApi> loadAndParseToObject(String openApiPath) async {
    final file = File(openApiPath);
    var openAPIAsString = await file.readAsString();
    if (RegExp("^.*.(yaml|yml)\$").hasMatch(file.path.toLowerCase())) {
      final openAPIAsYaml = loadYaml(openAPIAsString);
      openAPIAsString = json.encode(openAPIAsYaml);
    }
    final openAPIAsJson = jsonDecode(openAPIAsString);
    return OpenApi.fromJson(openAPIAsJson);
  }

  static dynamic loadAndParseToMap(String openApiPath) async {
    final file = File(openApiPath);
    var openAPIAsString = await file.readAsString();
    if (RegExp("^.*.(yaml|yml)\$").hasMatch(file.path.toLowerCase())) {
      final openAPIAsYaml = loadYaml(openAPIAsString);
      openAPIAsString = json.encode(openAPIAsYaml);
    }
    return jsonDecode(openAPIAsString);
  }

  static bool isExtensionSupported(String filename) {
    return RegExp("^.*.(yaml|yml|json)\$").hasMatch(filename.toLowerCase());
  }

  @JsonKey(name: 'info')
  final APIInfo info;
  @JsonKey(name: 'x-ibm-configuration')
  final IbmConfiguration ibmConfiguration;

  OpenApi({
    required this.info,
    required this.ibmConfiguration,
  });

  factory OpenApi.fromJson(Map<String, dynamic> json) =>
      _$OpenApiFromJson(json);

  Map<String, dynamic> toJson() => _$OpenApiToJson(this);
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

@JsonSerializable()
class IbmConfiguration {
  final APIAssembly assembly;

  @JsonKey(name: 'type')
  final String apiType;

  @JsonKey(name: 'wsdl-definition')
  final WsdlDefinition? wsdlDefinition;

  IbmConfiguration({
    required this.assembly,
    required this.apiType,
    required this.wsdlDefinition,
  });

  factory IbmConfiguration.fromJson(Map<String, dynamic> json) =>
      _$IbmConfigurationFromJson(json);
  Map<String, dynamic> toJson() => _$IbmConfigurationToJson(this);
}

@JsonSerializable()
class APIAssembly {
  @JsonKey(name: 'execute')
  final List<dynamic>? executeList;
  @JsonKey(name: 'catch')
  final List<dynamic>? catchList;

  APIAssembly({
    required this.executeList,
    required this.catchList,
  });

  factory APIAssembly.fromJson(Map<String, dynamic> json) =>
      _$APIAssemblyFromJson(json);
  Map<String, dynamic> toJson() => _$APIAssemblyToJson(this);
}

@JsonSerializable()
class WsdlDefinition {
  @JsonKey(name: 'wsdl')
  final String wsdlFileRelativePath;

  @JsonKey(name: 'service')
  final String service;

  @JsonKey(name: 'port')
  final String port;

  @JsonKey(name: 'soap-version')
  final String soapVersion;

  WsdlDefinition({
    required this.wsdlFileRelativePath,
    required this.service,
    required this.port,
    required this.soapVersion,
  });

  factory WsdlDefinition.fromJson(Map<String, dynamic> json) =>
      _$WsdlDefinitionFromJson(json);
  Map<String, dynamic> toJson() => _$WsdlDefinitionToJson(this);
}
