import 'package:json_annotation/json_annotation.dart';

import '../http_headers.dart';
import './login_request_body.dart';

part 'login_request.g.dart';

@JsonSerializable()
class LoginRequest {
  @JsonKey(name: 'headers', required: true)
  HTTPHeaders headers;

  @JsonKey(name: 'body', required: true)
  LoginRequestBody body;

  LoginRequest(this.body, this.headers);

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() {
    return "Headers: ${headers.toString()}\nBody: ${body.toJson()}";
  }
}
