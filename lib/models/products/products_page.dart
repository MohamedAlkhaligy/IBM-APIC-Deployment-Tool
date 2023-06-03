import 'product_manage_meta.dart';

class ProductsPage {
  int totalCatalogProducts;
  List<ProductManageMeta> currentProductsSubset;

  ProductsPage({
    required this.totalCatalogProducts,
    required this.currentProductsSubset,
  });
}
