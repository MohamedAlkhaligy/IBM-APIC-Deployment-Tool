import 'package:json_annotation/json_annotation.dart';

import '../../../../models/products/api_meta.dart';
import '../../../../models/products/plan_meta.dart';
import '../../../../models/products/product_manage_meta.dart';
import 'product_dto.dart';

part 'list_products_response_dto.g.dart';

@JsonSerializable()
class ListProductsResponseDto {
  @JsonKey(name: 'total_results', required: true)
  final int totalResults;

  @JsonKey(name: 'results', required: true)
  final List<ProductDto> result;

  ListProductsResponseDto(this.totalResults, this.result);

  factory ListProductsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ListProductsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ListProductsResponseDtoToJson(this);

  List<ProductManageMeta> convertToProductManageMeta() {
    List<ProductManageMeta> products = [];

    for (final product in result) {
      Map<String, PlanMeta> plans = {};
      Map<String, ApiMeta> allAPIs = {};
      // Show all APIs
      for (final api in product.apis!) {
        allAPIs[api.id!] = (ApiMeta(
            name: api.name!, title: api.title!, version: api.version!));
      }
      plans[PlanMeta.NONE] = PlanMeta(
        title: PlanMeta.NONE,
        name: PlanMeta.NONE,
        apis: allAPIs.values.toList(),
      );

      // Show APIs per plan
      if (product.plans != null) {
        for (final plan in product.plans!) {
          List<ApiMeta> apis = [];
          if (plan.apis != null) {
            for (final api in plan.apis!) {
              apis.add(allAPIs[api.id!]!);
            }
          }
          plans[plan.name!] = PlanMeta(
            title: plan.title!,
            name: plan.name!,
            apis: apis,
          );
        }
      }
      products.add(ProductManageMeta(
          name: product.name!,
          title: product.title!,
          version: product.version!,
          state: product.state!,
          updatedAt: product.updatedAt!,
          plans: plans,
          selectedPlan: PlanMeta.NONE));
    }
    return products;
  }
}
