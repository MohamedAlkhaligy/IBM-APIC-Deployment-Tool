// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HTTPErrorResponse _$HTTPErrorResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['status', 'message'],
  );
  return HTTPErrorResponse(
    json['status'] as int,
    (json['message'] as List<dynamic>).map((e) => e as String).toList(),
    errors:
        (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$HTTPErrorResponseToJson(HTTPErrorResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'errors': instance.errors,
    };
