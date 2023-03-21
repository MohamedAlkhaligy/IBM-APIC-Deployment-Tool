// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_headers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HTTPHeaders _$HTTPHeadersFromJson(Map<String, dynamic> json) => HTTPHeaders(
      xProxyTargetURL: json['x-proxy-target-url'] as String?,
      xProxyOperationID: json['x-proxy-operation-id'] as String?,
      accept: json['Accept'] as String?,
      authorization: json['Authorization'] as String?,
      contentType: json['Content-Type'] as String?,
      location: json['Location'] as String?,
      clientId: json['X-Ibm-Client-Id'] as String?,
      clientSecret: json['X-Ibm-Client-Secret'] as String?,
      accessControlAllowOrigin: json['Access-Control-Allow-Origin'] as String?,
    );

Map<String, dynamic> _$HTTPHeadersToJson(HTTPHeaders instance) =>
    <String, dynamic>{
      'x-proxy-target-url': instance.xProxyTargetURL,
      'x-proxy-operation-id': instance.xProxyOperationID,
      'Accept': instance.accept,
      'Authorization': instance.authorization,
      'Content-Type': instance.contentType,
      'Location': instance.location,
      'X-Ibm-Client-Id': instance.clientId,
      'X-Ibm-Client-Secret': instance.clientSecret,
      'Access-Control-Allow-Origin': instance.accessControlAllowOrigin,
    };
