import 'api_meta.dart';

class PlanMeta {
  String title;
  String name;
  List<ApiMeta> apis;

  // ignore: constant_identifier_names
  static const NONE = "none";

  PlanMeta({
    required this.title,
    required this.name,
    required this.apis,
  });
}
