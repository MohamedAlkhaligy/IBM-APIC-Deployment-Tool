import 'package:ibm_apic_dt/global_configurations.dart';
import 'package:ibm_apic_dt/models/catalogs/catalog.dart';
import 'package:ibm_apic_dt/models/environment.dart';
import 'package:ibm_apic_dt/models/organizations/organization.dart';

import '../models/products/product_manage_meta.dart';
import '../services/catalogs_service.dart';
import '../services/organization_service.dart';
import '../services/product_service.dart';

class ProductsManageController {
  final Environment _environment;

  int _organizationIndex,
      _catalogIndex,
      _productsSelected,
      _offset,
      _limit,
      _totalCatalogProducts;

  RetrievalType _retrievalType;

  List<Organization> orgs;
  List<Catalog> catalogs;
  List<ProductManageMeta> _products;
  String _searchBy;

  ProductsManageController(this._environment)
      : _organizationIndex = 0,
        _catalogIndex = 0,
        _productsSelected = 0,
        _offset = 0,
        _limit = 10,
        _totalCatalogProducts = 0,
        _retrievalType = RetrievalType.pages,
        orgs = [],
        catalogs = [],
        _products = [],
        _searchBy = "";

  int get productsSelected => _productsSelected;

  set productsSelected(int value) => _productsSelected = value;

  int get organizationIndex => _organizationIndex;

  set organizationIndex(int value) => _organizationIndex = value;

  int get catalogIndex => _catalogIndex;

  set catalogIndex(int value) => _catalogIndex = value;

  int get limit => _limit;

  int get offset => _offset;

  RetrievalType get retrievalType => _retrievalType;

  int get totalCatalogProducts => _totalCatalogProducts;

  int get numberOfPages => (_totalCatalogProducts / _limit).ceil();

  int get pageNumber => (_offset / _limit).floor() + 1;

  List<ProductManageMeta> get products {
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(_searchBy.toLowerCase().trim()))
        .toList();
  }

  void sort(SortType sortType) {
    switch (sortType) {
      case SortType.ascending:
        _products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.created:
        break;
      case SortType.descending:
        _products.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortType.recent:
        break;
      case SortType.none:
        break;
    }
  }

  void searchProduct(String name) {
    _searchBy = name;
  }

  /// Change the number of products per page,
  /// where [limit] is the number of products per page
  Future<void> changeLimit(int limit) async {
    if (limit == _limit) return;
    _limit = limit;
    await _loadProducts(
        orgs[organizationIndex].name!, catalogs[catalogIndex].name);
  }

  Future<void> changePageNumber(int pageNumber) async {
    int newOffset = (pageNumber - 1) * _limit;
    if (_offset == newOffset) return;
    _offset = newOffset;
    await _loadProducts(
        orgs[organizationIndex].name!, catalogs[catalogIndex].name);
  }

  Future<void> changeRetrievalType(RetrievalType retrievalType) async {
    if (_retrievalType == retrievalType) return;
    _retrievalType = retrievalType;
    await _loadProducts(
        orgs[organizationIndex].name!, catalogs[catalogIndex].name);
  }

  Future<void> _loadProducts(
      String organizationName, String catalogName) async {
    String queryParamters =
        "fields=name,title,version,state,updated_at,plans,apis&expand=apis";
    if (_retrievalType == RetrievalType.pages) {
      queryParamters += "&limit=$_limit&offset=$_offset";
    }
    final productPage = await ProductService.getInstance().listProducts(
      _environment,
      organizationName,
      catalogName,
      queryParameters: queryParamters,
    );
    _totalCatalogProducts = productPage.totalCatalogProducts;
    _products = productPage.currentProductsSubset;
  }

  Future<void> loadData() async {
    orgs = await OrganizationsService.getInstance()
        .listOrgs(_environment, queryParameters: "fields=name,title,owner_url");
    if (orgs.isEmpty) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[0].name!,
        queryParameters: "fields=name,title");

    await _loadProducts(orgs[0].name!, catalogs[0].name);
  }

  Future<void> _applyOrganizationChanges() async {
    _catalogIndex = 0;
    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name,title");
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
    _products = [];
    if (catalogs.isNotEmpty && orgs.isNotEmpty) {
      await _loadProducts(
        orgs[_organizationIndex].name!,
        catalogs[_catalogIndex].name,
      );
    }
  }

  void _clearData() {
    orgs = [];
    catalogs = [];
    _products = [];
  }

  Future<void> refreshData() async {
    _clearData();
    orgs = await OrganizationsService.getInstance()
        .listOrgs(_environment, queryParameters: "fields=name,title,owner_url");
    if (orgs.isEmpty || _organizationIndex >= orgs.length) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name,title");
    if (catalogs.isEmpty || _catalogIndex >= catalogs.length) return;
    await _loadProducts(
        orgs[organizationIndex].name!, catalogs[catalogIndex].name);
  }
}
