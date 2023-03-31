import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../errors/openapi_type_not_supported.dart';
import '../errors/path_not_file_exception.dart';
import '../global_configurations.dart';
import '../models/catalogs/catalog.dart';
import '../models/environment.dart';
import '../models/organizations/organization.dart';
import '../models/products/openapi.dart';
import '../models/products/product_info.dart';
import '../services/catalogs_service.dart';
import '../services/organization_service.dart';
import '../services/product_service.dart';
import '../utilities/error_handling_utilities.dart';

class ProductController {
  final List<ProductInfo> _productsInfos;
  final Environment _environment;

  int _organizationIndex, _catalogIndex, _productsSelected;
  List<Organization> orgs;
  List<Catalog> catalogs;
  String _searchBy = "";

  ProductController(this._environment)
      : _organizationIndex = 0,
        _catalogIndex = 0,
        _productsSelected = 0,
        orgs = [],
        catalogs = [],
        _productsInfos = [];

  List<ProductInfo> get productsInfos {
    return _productsInfos
        .where((productInfo) => productInfo.name
            .toLowerCase()
            .contains(_searchBy.toLowerCase().trim()))
        .toList();
  }

  void searchProduct(String name) {
    _searchBy = name;
  }

  int get productsSelected => _productsSelected;

  set productsSelected(int value) => _productsSelected = value;

  int get organizationIndex => _organizationIndex;

  set organizationIndex(int value) => _organizationIndex = value;

  int get catalogIndex => _catalogIndex;

  set catalogIndex(int value) => _catalogIndex = value;

  void sort(SortType sortType) {
    switch (sortType) {
      case SortType.ascending:
        _productsInfos.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.created:
        break;
      case SortType.descending:
        _productsInfos.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortType.recent:
        break;
    }
  }

  void _clearData() {
    orgs = [];
    catalogs = [];
  }

  void unLoadProducts() {
    _productsInfos.clear();
  }

  bool areDataAvailable() {
    return orgs.isNotEmpty && catalogs.isNotEmpty;
  }

  Future<bool> publish(index) async {
    return await ProductService.getInstance().publish(
      _environment,
      orgs[_organizationIndex].name!,
      catalogs[_catalogIndex].name,
      _productsInfos[index],
      queryParameters: "migrate_subscriptions=true",
    );
  }

  Future<void> publishSelected() async {
    if (_productsSelected == 0) {
      ErrorHandlingUtilities.instance
          .showPopUpError("Please select a product to publish!");
    } else {
      for (final productInfos in _productsInfos) {
        if (productInfos.isSelected) {
          final hasPublished = await ProductService.getInstance().publish(
            _environment,
            orgs[_organizationIndex].name!,
            catalogs[_catalogIndex].name,
            productInfos,
            queryParameters: "migrate_subscriptions=true",
          );

          if (!hasPublished) {
            bool isContinue = await ErrorHandlingUtilities.instance
                    .showPopUpErrorWithDilemma(
                        "An error occured while publishing ${productInfos.name}:${productInfos.version}. Do you wish to continue with other products?") ??
                false;
            if (!isContinue) {
              break;
            }
          }
        }
      }
    }
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

  Future<bool> loadProducts(
    List<XFile> files, {
    bool ignoreError = true,
  }) async {
    try {
      for (final file in files) {
        if (await FileSystemEntity.isDirectory(file.path) &&
            files.length == 1) {
          await ErrorHandlingUtilities.instance
              .showPopUpError("Drag product files only!");
          return false;
        } else if (RegExp("^.*.(yaml|yml)\$")
            .hasMatch(file.name.toLowerCase())) {
          // Publish product
          await _addProduct(file, ignoreError: ignoreError);
        }
      }
      if (_productsInfos.isNotEmpty) {
        return true;
      } else {
        await ErrorHandlingUtilities.instance
            .showPopUpError("No valid yaml-based product file has been found");
      }
    } catch (error, stackTrace) {
      if (!ignoreError) {
        ErrorHandlingUtilities.instance.showPopUpError(error.toString());
      }
      GlobalConfigurations.logger.e(
        "ProductsSubScreen:DragAndDrop",
        error,
        stackTrace,
      );
    }
    return false;
  }

  Future<void> _addProduct(
    XFile productFile, {
    bool ignoreError = true,
  }) async {
    try {
      // Parse file to product
      final product =
          await ProductService.getInstance().loadProduct(productFile.path);

      // Only check if the apis exist
      for (final entry in product.apis.entries) {
        final api = entry.value;
        String openAPIPath = path.join(
            path.dirname(productFile.path), api.ref.replaceAll("/", "\\"));
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

        // This is to check if the yaml file contains api info object giving
        // higher chance that this is an api file. The actaul validation is done
        // from the api management server when the product is published
        final openAPIAsString = await File(openAPIPath).readAsString();
        final openAPIAsYaml = loadYaml(openAPIAsString);
        final openAPIAsJson = jsonDecode(json.encode(openAPIAsYaml));
        OpenAPI.fromJson(openAPIAsJson);
      }

      // Validation Done
      // Add product to list of products
      _productsInfos.add(
        ProductInfo(
          filePath: productFile.path,
          name: product.info.name,
          version: product.info.version,
        ),
      );
      print(_productsInfos);
    } catch (error, traceStack) {
      GlobalConfigurations.logger.e(
        "ProductsSubScreen:addProduct:${productFile.path}",
        error,
        traceStack,
      );
      if (!ignoreError) {
        await ErrorHandlingUtilities.instance.showPopUpError(
            "Error loading the product: ${productFile.name}\nPath: ${productFile.path}\nError: $error");
      }
    }
  }
}
