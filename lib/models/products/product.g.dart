// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      info: Info.fromJson(json['info'] as Map<String, dynamic>),
      gateways:
          (json['gateways'] as List<dynamic>).map((e) => e as String).toList(),
      plans: (json['plans'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, PlanDetails.fromJson(e as Map<String, dynamic>)),
      ),
      apis: (json['apis'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, Api.fromJson(e as Map<String, dynamic>)),
      ),
      visibility:
          VisibilityDto.fromJson(json['visibility'] as Map<String, dynamic>),
      productVersion: json['product'] as String,
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'info': instance.info,
      'gateways': instance.gateways,
      'plans': instance.plans,
      'apis': instance.apis,
      'visibility': instance.visibility,
      'product': instance.productVersion,
    };

Info _$InfoFromJson(Map<String, dynamic> json) => Info(
      version: json['version'] as String,
      title: json['title'] as String?,
      name: json['name'] as String,
    );

Map<String, dynamic> _$InfoToJson(Info instance) {
  final val = <String, dynamic>{
    'version': instance.version,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('title', instance.title);
  val['name'] = instance.name;
  return val;
}

PlanDetails _$PlanDetailsFromJson(Map<String, dynamic> json) => PlanDetails(
      rateLimits: (json['rate-limits'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, LimitDetails.fromJson(e as Map<String, dynamic>)),
      ),
      burstLimits: (json['burst-limits'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, LimitDetails.fromJson(e as Map<String, dynamic>)),
      ),
      title: json['title'] as String?,
      description: json['description'] as String?,
      approval: json['approval'] as bool?,
      apis: (json['apis'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, PlanAPIs.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$PlanDetailsToJson(PlanDetails instance) {
  final val = <String, dynamic>{
    'rate-limits': instance.rateLimits.map((k, e) => MapEntry(k, e.toJson())),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('burst-limits',
      instance.burstLimits?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('title', instance.title);
  writeNotNull('description', instance.description);
  writeNotNull('approval', instance.approval);
  writeNotNull('apis', instance.apis?.map((k, e) => MapEntry(k, e.toJson())));
  return val;
}

PlanAPIs _$PlanAPIsFromJson(Map<String, dynamic> json) => PlanAPIs(
      operations: (json['operations'] as List<dynamic>?)
          ?.map((e) => Operation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlanAPIsToJson(PlanAPIs instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('operations', instance.operations);
  return val;
}

Operation _$OperationFromJson(Map<String, dynamic> json) => Operation(
      operation: json['operation'] as String,
      path: json['path'] as String,
    );

Map<String, dynamic> _$OperationToJson(Operation instance) => <String, dynamic>{
      'operation': instance.operation,
      'path': instance.path,
    };

LimitDetails _$LimitDetailsFromJson(Map<String, dynamic> json) => LimitDetails(
      value: json['value'] as String,
      hardLimit: json['hard-limit'] as bool?,
    );

Map<String, dynamic> _$LimitDetailsToJson(LimitDetails instance) {
  final val = <String, dynamic>{
    'value': instance.value,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('hard-limit', instance.hardLimit);
  return val;
}

Api _$ApiFromJson(Map<String, dynamic> json) => Api(
      ref: json[r'$ref'] as String,
    );

Map<String, dynamic> _$ApiToJson(Api instance) => <String, dynamic>{
      r'$ref': instance.ref,
    };
