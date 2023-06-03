import 'plan_meta.dart';

class ProductManageMeta {
  bool isSelected;
  String name;
  String title;
  String version;
  String state;
  String updatedAt;
  Map<String, PlanMeta> plans;
  String selectedPlan;

  ProductManageMeta({
    required this.name,
    required this.title,
    required this.version,
    required this.state,
    required this.updatedAt,
    this.isSelected = false,
    required this.selectedPlan,
    required this.plans,
  });
}
