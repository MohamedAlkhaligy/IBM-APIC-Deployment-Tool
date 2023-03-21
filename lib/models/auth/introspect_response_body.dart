import 'package:json_annotation/json_annotation.dart';

part 'introspect_response_body.g.dart';

@JsonSerializable()
class IntrospectResponseBody {
  @JsonKey(
    name: 'type',
  )
  final String? type;

  @JsonKey(
    name: 'api_version',
  )
  final String? apiVersion;

  @JsonKey(
    name: 'name',
  )
  final String? name;

  @JsonKey(
    name: 'state',
  )
  final String? state;

  @JsonKey(
    name: 'identity_provider',
  )
  final String? identityProvider;

  @JsonKey(
    name: 'username',
  )
  final String? username;

  @JsonKey(
    name: 'email',
  )
  final String? email;

  @JsonKey(
    name: 'first_name',
  )
  final String? firstName;

  @JsonKey(
    name: 'last_name',
  )
  final String? lastName;

  @JsonKey(
    name: 'url',
  )
  final String? url;

  IntrospectResponseBody(
      this.type,
      this.apiVersion,
      this.name,
      this.state,
      this.identityProvider,
      this.username,
      this.email,
      this.firstName,
      this.lastName,
      this.url);

  factory IntrospectResponseBody.fromJson(Map<String, dynamic> json) =>
      _$IntrospectResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$IntrospectResponseBodyToJson(this);
}
