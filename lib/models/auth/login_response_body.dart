import 'package:json_annotation/json_annotation.dart';

part 'login_response_body.g.dart';

@JsonSerializable()
class LoginResponseBody {
  @JsonKey(name: 'access_token', required: true)
  final String accessToken;

  @JsonKey(name: 'token_type', required: true)
  final String tokenType;

  @JsonKey(name: 'expires_in', required: true)
  final int expiresIn;

  LoginResponseBody(
    this.accessToken,
    this.tokenType,
    this.expiresIn,
  );

  factory LoginResponseBody.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseBodyToJson(this);
}
