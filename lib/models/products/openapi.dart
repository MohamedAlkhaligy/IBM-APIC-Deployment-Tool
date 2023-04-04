import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';

part 'openapi.g.dart';

@JsonSerializable()
class OpenAPI {
  static Future<OpenAPI> loadOpenAPI(File file) async {
    var openAPIAsString = await file.readAsString();
    if (RegExp("^.*.(yaml|yml)\$").hasMatch(file.path.toLowerCase())) {
      final openAPIAsYaml = loadYaml(openAPIAsString);
      openAPIAsString = json.encode(openAPIAsYaml);
    }
    final openAPIAsJson = jsonDecode(openAPIAsString);
    return OpenAPI.fromJson(openAPIAsJson);
  }

  static bool isExtensionSupported(String filename) {
    return RegExp("^.*.(yaml|yml|json)\$").hasMatch(filename.toLowerCase());
  }

  @JsonKey(name: 'info')
  final APIInfo info;
  @JsonKey(name: 'x-ibm-configuration')
  final IbmConfiguration ibmConfiguration;

  OpenAPI({
    required this.info,
    required this.ibmConfiguration,
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

@JsonSerializable()
class IbmConfiguration {
  final APIAssembly assembly;

  IbmConfiguration({required this.assembly});

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

  APIAssembly({required this.executeList, required this.catchList});

  factory APIAssembly.fromJson(Map<String, dynamic> json) =>
      _$APIAssemblyFromJson(json);
  Map<String, dynamic> toJson() => _$APIAssemblyToJson(this);
}
