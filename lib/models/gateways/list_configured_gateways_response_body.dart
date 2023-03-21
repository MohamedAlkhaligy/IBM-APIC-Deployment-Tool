import 'package:json_annotation/json_annotation.dart';

import './configured_gateway.dart';

part 'list_configured_gateways_response_body.g.dart';

@JsonSerializable()
class ListConfiguredGatewaysResponseBody {
  @JsonKey(name: 'total_results', required: true)
  final int totalResults;

  @JsonKey(name: 'results', required: true)
  final List<ConfiguredGateway> result;

  ListConfiguredGatewaysResponseBody(this.totalResults, this.result);

  factory ListConfiguredGatewaysResponseBody.fromJson(
          Map<String, dynamic> json) =>
      _$ListConfiguredGatewaysResponseBodyFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ListConfiguredGatewaysResponseBodyToJson(this);
}
