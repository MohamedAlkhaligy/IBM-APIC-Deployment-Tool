import 'package:json_annotation/json_annotation.dart';

part 'http_headers.g.dart';

@JsonSerializable()
class HTTPHeaders {
  @JsonKey(name: 'x-proxy-target-url')
  String? xProxyTargetURL;

  @JsonKey(name: 'x-proxy-operation-id')
  String? xProxyOperationID;

  @JsonKey(name: 'Accept')
  String? accept;

  @JsonKey(name: 'Authorization')
  String? authorization;

  @JsonKey(name: 'Content-Type')
  String? contentType;

  @JsonKey(name: 'Location')
  String? location;

  @JsonKey(name: 'X-Ibm-Client-Id')
  String? clientId;

  @JsonKey(name: 'X-Ibm-Client-Secret')
  String? clientSecret;

  @JsonKey(name: 'Access-Control-Allow-Origin')
  String? accessControlAllowOrigin;

  HTTPHeaders({
    this.xProxyTargetURL,
    this.xProxyOperationID,
    this.accept,
    this.authorization,
    this.contentType,
    this.location,
    this.clientId,
    this.clientSecret,
    this.accessControlAllowOrigin,
  });

  Map<String, String> get typedJson {
    return {
      if (xProxyTargetURL != null) 'x-proxy-target-url': xProxyTargetURL!,
      if (xProxyOperationID != null) 'x-proxy-operation-id': xProxyOperationID!,
      if (accept != null) 'Accept': accept!,
      if (authorization != null) 'Authorization': "Bearer $authorization",
      if (contentType != null) 'Content-Type': contentType!,
      if (location != null) 'Location': location!,
      if (clientId != null) 'X-Ibm-Client-Id': clientId!,
      if (clientSecret != null) 'X-Ibm-Client-Secret': clientSecret!,
      if (accessControlAllowOrigin != null)
        'Access-Control-Allow-Origin': accessControlAllowOrigin!,
    };
  }

  @override
  String toString() {
    return typedJson.toString();
  }

  factory HTTPHeaders.fromJson(Map<String, dynamic> json) =>
      _$HTTPHeadersFromJson(json);

  Map<String, dynamic> toJson() => _$HTTPHeadersToJson(this);
}
