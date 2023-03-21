import 'package:json_annotation/json_annotation.dart';

part 'login_request_body.g.dart';

@JsonSerializable()
class LoginRequestBody {
  @JsonKey(name: 'client_id', required: true)
  String clientID;

  @JsonKey(name: 'client_secret', required: true)
  String clientSecret;

  @JsonKey(name: 'grant_type')
  final String grantType;

  @JsonKey(name: 'password', required: true)
  String password;

  @JsonKey(name: 'realm', required: true)
  String realm;

  @JsonKey(name: 'username', required: true)
  String username;

  LoginRequestBody(
    this.clientID,
    this.clientSecret,
    this.password,
    this.realm,
    this.username, {
    this.grantType = 'password',
  });

  factory LoginRequestBody.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestBodyToJson(this);
}
