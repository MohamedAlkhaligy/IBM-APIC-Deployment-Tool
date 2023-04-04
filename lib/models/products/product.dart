import 'dart:convert';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:yaml/yaml.dart';

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
  final Map<String, Api> apis;

  @JsonKey(name: 'visibility')
  final Visibility visibility;

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
  final Map<String, Details> rateLimits;

  @JsonKey(name: 'burst-limits', includeIfNull: false)
  final Map<String, Details>? burstLimits;

  @JsonKey(name: 'title', includeIfNull: false)
  final String? title;

  @JsonKey(name: 'description', includeIfNull: false)
  final String? description;

  @JsonKey(name: 'approval', includeIfNull: false)
  final bool? approval;

  PlanDetails({
    required this.rateLimits,
    this.burstLimits,
    required this.title,
    required this.description,
    required this.approval,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) =>
      _$PlanDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$PlanDetailsToJson(this);
}

@JsonSerializable()
class Details {
  @JsonKey(name: 'value')
  final String value;

  @JsonKey(name: 'hard-limit', includeIfNull: false)
  final bool? hardLimit;

  Details({required this.value, this.hardLimit});

  factory Details.fromJson(Map<String, dynamic> json) =>
      _$DetailsFromJson(json);
  Map<String, dynamic> toJson() => _$DetailsToJson(this);
}

@JsonSerializable()
class Api {
  @JsonKey(name: '\$ref')
  final String ref;

  Api({required this.ref});

  factory Api.fromJson(Map<String, dynamic> json) => _$ApiFromJson(json);
  Map<String, dynamic> toJson() => _$ApiToJson(this);
}

@JsonSerializable()
class Visibility {
  final View view;
  final Subscribe subscribe;

  Visibility({required this.view, required this.subscribe});

  factory Visibility.fromJson(Map<String, dynamic> json) =>
      _$VisibilityFromJson(json);
  Map<String, dynamic> toJson() => _$VisibilityToJson(this);
}

@JsonSerializable()
class View {
  final String type;
  final List<String> orgs;

  @JsonKey(name: 'tags', defaultValue: [])
  final List<String> tags;
  final bool enabled;

  View({
    required this.type,
    required this.orgs,
    required this.tags,
    required this.enabled,
  });

  factory View.fromJson(Map<String, dynamic> json) => _$ViewFromJson(json);
  Map<String, dynamic> toJson() => _$ViewToJson(this);
}

@JsonSerializable()
class Subscribe {
  final String type;
  final List<String> orgs;

  @JsonKey(name: 'tags', defaultValue: [])
  final List<String> tags;
  final bool enabled;

  Subscribe({
    required this.type,
    required this.orgs,
    required this.tags,
    required this.enabled,
  });

  factory Subscribe.fromJson(Map<String, dynamic> json) =>
      _$SubscribeFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeToJson(this);
}
