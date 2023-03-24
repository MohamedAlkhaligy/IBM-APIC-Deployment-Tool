import 'dart:convert';
import 'dart:io';

import 'package:ibm_apic_dt/errors/openapi_type_not_supported.dart';
import 'package:ibm_apic_dt/errors/path_not_file_exception.dart';
import 'package:ibm_apic_dt/models/products/openapi.dart';
import 'package:ibm_apic_dt/services/product_service.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:cross_file/cross_file.dart';

import 'package:ibm_apic_dt/global_configurations.dart';
import 'package:ibm_apic_dt/models/catalogs/catalog.dart';
import 'package:ibm_apic_dt/models/environment.dart';
import 'package:ibm_apic_dt/models/organizations/organization.dart';
import 'package:ibm_apic_dt/models/products/openapi_info.dart';
import 'package:ibm_apic_dt/models/products/product.dart';
import 'package:ibm_apic_dt/models/products/product_adaptor.dart';
import 'package:ibm_apic_dt/models/products/product_info.dart';
import 'package:ibm_apic_dt/services/catalogs_service.dart';
import 'package:ibm_apic_dt/services/organization_service.dart';
import 'package:yaml/yaml.dart';

class ProductController {
  int _organizationIndex, _catalogIndex, _productsSelected;
  List<Organization> orgs;
  List<Catalog> catalogs;
  List<ProductInfo> productsInfos;
  Environment _environment;

  ProductController(this._environment)
      : _organizationIndex = 0,
        _catalogIndex = 0,
        _productsSelected = 0,
        orgs = [],
        catalogs = [],
        productsInfos = [];

  int get productsSelected => _productsSelected;

  set productsSelected(int value) => _productsSelected = value;

  int get organizationIndex => _organizationIndex;

  set organizationIndex(int value) => _organizationIndex = value;

  int get catalogIndex => _catalogIndex;

  set catalogIndex(int value) => _catalogIndex = value;

  void _clearData() {
    orgs = [];
    catalogs = [];
  }

  bool areDataAvailable() {
    return orgs.isNotEmpty && catalogs.isNotEmpty;
  }

  Future<bool> publish(index) async {
    return await ProductService.getInstance().publish(
        _environment,
        orgs[_organizationIndex].name!,
        catalogs[_catalogIndex].name,
        productsInfos[index]);
  }

  Future<void> refreshData() async {
    _clearData();
    orgs = await OrganizationsService.getInstance().listOrgs(_environment,
        queryParameters: "fields=name&fields=title&fields=owner_url");
    if (orgs.isEmpty || _organizationIndex >= orgs.length) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty || _catalogIndex >= catalogs.length) return;
  }

  Future<void> loadData() async {
    orgs = await OrganizationsService.getInstance().listOrgs(_environment,
        queryParameters: "fields=name&fields=title&fields=owner_url");
    if (orgs.isEmpty) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[0].name!,
        queryParameters: "fields=name&fields=title");
  }

  Future<void> _applyOrganizationChanges() async {
    _catalogIndex = 0;
    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty) return;
  }

  Future<void> applyChange(ChangeType changeType) async {
    switch (changeType) {
      case ChangeType.organization:
        await _applyOrganizationChanges();
        break;
      case ChangeType.catalog:
        break;
      case ChangeType.configuredGateway:
        break;
      case ChangeType.mediaType:
        break;
    }
  }

  Future<void> addProduct(XFile file) async {
    Map<String, ApiAdaptor> apis = {};
    List<OpenAPIInfo> openAPIInfos = [];
    try {
      // Parse file to product
      String productAsString = await File(file.path).readAsString();
      final productAsYaml = loadYaml(productAsString);
      final productAsJson = jsonDecode(json.encode(productAsYaml));
      final product = Product.fromJson(productAsJson);

      // Check if the product APIs exist

      product.apis.forEach((key, api) async {
        String openAPIPath =
            path.join(path.dirname(file.path), api.ref.replaceAll("/", "\\"));
        if (!await FileSystemEntity.isFile(openAPIPath)) {
          throw PathNotFileException(
              "One or more oh the API paths provided in the ${product.info.name}:${product.info.version} are not valid file path");
        }

        String openAPIFilename = path.basename(openAPIPath);
        if (!RegExp("^.*.(yaml|yml)\$")
            .hasMatch(openAPIFilename.toLowerCase())) {
          throw OpenAPITypeNotSupported(
              "One or more oh the API paths provided in the ${product.info.name}:${product.info.version} are not yaml-based");
        }

        final openAPIAsString = await File(openAPIPath).readAsString();
        final openAPIAsYaml = loadYaml(openAPIAsString);
        final openAPIAsJson = jsonDecode(json.encode(openAPIAsYaml));
        final openAPI = OpenAPI.fromJson(openAPIAsJson);

        apis[key] =
            ApiAdaptor(name: "${openAPI.info.name}:${openAPI.info.version}");
        openAPIInfos.add(
          OpenAPIInfo(
              path: openAPIPath,
              filename: openAPIFilename,
              name: openAPI.info.name,
              version: openAPI.info.version),
        );
      });

      // Validation Done
      // Add product to list of products
      productsInfos.add(
        ProductInfo(
          openAPIInfos: openAPIInfos,
          adaptor: ProductAdaptor.fromProduct(product, apis),
        ),
      );
    } catch (error, traceStack) {
      Logger()
          .e("ProductsSubScreen:addProduct:${file.name}", error, traceStack);
    }
  }
}
