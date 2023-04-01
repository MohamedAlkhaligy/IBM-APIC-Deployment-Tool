import 'package:json_annotation/json_annotation.dart';

part 'global_policy.g.dart';

@JsonSerializable()
class GlobalPolicy {
  @JsonKey(name: 'global-policy')
  final String globalPolicy;
  final Info info;
  final List<String> gateways;
  final Assembly assembly;

  GlobalPolicy({
    required this.globalPolicy,
    required this.info,
    required this.gateways,
    required this.assembly,
  });

  factory GlobalPolicy.fromJson(Map<String, dynamic> json) =>
      _$GlobalPolicyFromJson(json);
  Map<String, dynamic> toJson() => _$GlobalPolicyToJson(this);
}

@JsonSerializable()
class Info {
  final String name;
  final String? title;
  final String version;

  Info({required this.name, required this.title, required this.version});

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
  Map<String, dynamic> toJson() => _$InfoToJson(this);
}

@JsonSerializable()
class Assembly {
  @JsonKey(name: 'execute', includeIfNull: false)
  final List<dynamic>? executeList;
  @JsonKey(name: 'catch', defaultValue: [])
  final List<dynamic>? catchList;

  Assembly({required this.executeList, required this.catchList});

  factory Assembly.fromJson(Map<String, dynamic> json) =>
      _$AssemblyFromJson(json);
  Map<String, dynamic> toJson() => _$AssemblyToJson(this);
}
