import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';

import '../../dtos/common/visibility_dto.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  @JsonKey(name: 'info')
  final Info info;

  @JsonKey(name: 'gateways')
  final List<String> gateways;

  @JsonKey(name: 'plans')
  final Map<String, PlanDetails> plans;

  @JsonKey(name: 'apis')
  final Map<String, ApiFileReference> apis;

  @JsonKey(name: 'visibility')
  final VisibilityDto visibility;

  @JsonKey(name: 'product')
  final String productVersion;

  Product({
    required this.info,
    required this.gateways,
    required this.plans,
    required this.apis,
    required this.visibility,
    required this.productVersion,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  static Future<Product> loadFromFile(File file) async {
    var productAsString = await file.readAsString();
    if (RegExp("^.*.(yaml|yml)\$").hasMatch(file.path.toLowerCase())) {
      final productAsYaml = loadYaml(productAsString);
      productAsString = json.encode(productAsYaml);
    }
    final productAsJson = jsonDecode(productAsString);
    return Product.fromJson(productAsJson);
  }

  static bool isExtensionSupported(String filename) {
    return RegExp("^.*.(yaml|yml|json)\$").hasMatch(filename.toLowerCase());
  }
}

@JsonSerializable()
class Info {
  @JsonKey(name: 'version')
  final String version;

  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;

  @JsonKey(name: 'name')
  final String name;

  Info({
    required this.version,
    required this.title,
    required this.name,
  });

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
  Map<String, dynamic> toJson() => _$InfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PlanDetails {
  @JsonKey(name: 'rate-limits')
  final Map<String, LimitDetails> rateLimits;

  @JsonKey(name: 'burst-limits', includeIfNull: false)
  final Map<String, LimitDetails>? burstLimits;

  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;

  @JsonKey(name: 'description', includeIfNull: false)
  final String? description;

  @JsonKey(name: 'approval', includeIfNull: false)
  final bool? approval;

  @JsonKey(name: 'apis', includeIfNull: false)
  final Map<String, PlanAPIs>? apis;

  PlanDetails({
    required this.rateLimits,
    this.burstLimits,
    required this.title,
    required this.description,
    required this.approval,
    this.apis,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) =>
      _$PlanDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$PlanDetailsToJson(this);
}

@JsonSerializable()
class PlanAPIs {
  @JsonKey(name: 'operations', includeIfNull: false)
  List<Operation>? operations;

  PlanAPIs({this.operations});

  factory PlanAPIs.fromJson(Map<String, dynamic> json) =>
      _$PlanAPIsFromJson(json);
  Map<String, dynamic> toJson() => _$PlanAPIsToJson(this);
}

@JsonSerializable()
class Operation {
  @JsonKey(name: 'operation')
  String operation;

  @JsonKey(name: 'path')
  String path;

  Operation({required this.operation, required this.path});

  factory Operation.fromJson(Map<String, dynamic> json) =>
      _$OperationFromJson(json);
  Map<String, dynamic> toJson() => _$OperationToJson(this);
}

@JsonSerializable()
class LimitDetails {
  @JsonKey(name: 'value')
  final String value;

  @JsonKey(name: 'hard-limit', includeIfNull: false)
  final bool? hardLimit;

  LimitDetails({required this.value, this.hardLimit});

  factory LimitDetails.fromJson(Map<String, dynamic> json) =>
      _$LimitDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$LimitDetailsToJson(this);
}

@JsonSerializable()
class ApiFileReference {
  @JsonKey(name: '\$ref')
  final String ref;

  ApiFileReference({required this.ref});

  factory ApiFileReference.fromJson(Map<String, dynamic> json) =>
      _$ApiFileReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$ApiFileReferenceToJson(this);
}
