import 'package:json_annotation/json_annotation.dart';

import './catalog.dart';

part 'list_catalogs_response_body.g.dart';

@JsonSerializable()
class ListCatalogsResponseBody {
  @JsonKey(name: 'total_results', required: true)
  final int totalResults;

  @JsonKey(name: 'results', required: true)
  final List<Catalog> result;

  ListCatalogsResponseBody(this.totalResults, this.result);

  factory ListCatalogsResponseBody.fromJson(Map<String, dynamic> json) =>
      _$ListCatalogsResponseBodyFromJson(json);

  Map<String, dynamic> toJson() => _$ListCatalogsResponseBodyToJson(this);
}
