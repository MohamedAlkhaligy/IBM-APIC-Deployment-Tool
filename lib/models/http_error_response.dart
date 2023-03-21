import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'http_error_response.g.dart';

@JsonSerializable()
class HTTPErrorResponse {
  @JsonKey(name: 'status', required: true)
  final int status;

  @JsonKey(name: 'message', required: true)
  final List<String> message;

  @JsonKey(name: 'errors')
  final List<String>? errors;

  HTTPErrorResponse(this.status, this.message, {this.errors});

  factory HTTPErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$HTTPErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HTTPErrorResponseToJson(this);

  String toJsonString() {
    return json.encode(this);
  }
}
