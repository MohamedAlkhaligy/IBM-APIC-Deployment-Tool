// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalPolicy _$GlobalPolicyFromJson(Map<String, dynamic> json) => GlobalPolicy(
      globalPolicy: json['global-policy'] as String,
      info: Info.fromJson(json['info'] as Map<String, dynamic>),
      gateways:
          (json['gateways'] as List<dynamic>).map((e) => e as String).toList(),
      assembly: Assembly.fromJson(json['assembly'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GlobalPolicyToJson(GlobalPolicy instance) =>
    <String, dynamic>{
      'global-policy': instance.globalPolicy,
      'info': instance.info,
      'gateways': instance.gateways,
      'assembly': instance.assembly,
    };

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
      name: json['name'] as String,
      title: json['title'] as String?,
      version: json['version'] as String,
    );

Map<String, dynamic> _$InfoToJson(Info instance) => <String, dynamic>{
      'name': instance.name,
      'title': instance.title,
      'version': instance.version,
    };

Assembly _$AssemblyFromJson(Map<String, dynamic> json) => Assembly(
      executeList: json['execute'] as List<dynamic>?,
      catchList: json['catch'] as List<dynamic>? ?? [],
    );

Map<String, dynamic> _$AssemblyToJson(Assembly instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('execute', instance.executeList);
  val['catch'] = instance.catchList;
  return val;
}
