import 'package:ibm_apic_dt/models/products/openapi_info.dart';
import 'package:ibm_apic_dt/models/products/product_adaptor.dart';

class ProductInfo {
  bool isSelected;
  List<OpenAPIInfo> openAPIInfos;
  ProductAdaptor adaptor;

  ProductInfo({
    required this.adaptor,
    required this.openAPIInfos,
    this.isSelected = false,
  });
}
