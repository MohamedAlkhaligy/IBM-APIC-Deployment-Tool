import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ibm_apic_dt/errors/openapi_type_not_supported.dart';
import 'package:ibm_apic_dt/errors/path_not_file_exception.dart';
import 'package:ibm_apic_dt/models/products/openapi.dart';
import 'package:ibm_apic_dt/models/products/openapi_info.dart';
import 'package:ibm_apic_dt/models/products/product_adaptor.dart';
import 'package:ibm_apic_dt/models/products/product_info.dart';
import 'package:ibm_apic_dt/services/product_service.dart';
import 'package:path/path.dart' as path;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/models/products/product.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import '../models/environment.dart';
import '../models/organizations/organization.dart';
import '../models/catalogs/catalog.dart';
import '../services/catalogs_service.dart';
import '../services/global_policies_service.dart';
import '../services/organization_service.dart';
import '../utilities/error_handling_utilities.dart';
import '../widgets/confirmation_pop_up.dart';
import '../widgets/loader.dart';
import '../global_configurations.dart';
import '../widgets/responsive_text.dart';

class ProductsSubScreen extends StatefulWidget {
  final Environment environment;

  const ProductsSubScreen(this.environment, {super.key});

  @override
  State<ProductsSubScreen> createState() => _ProductsSubScreenState();
}

class _ProductsSubScreenState extends State<ProductsSubScreen> {
  int _organizationIndex = 0, _catalogIndex = 0, productsSelected = 0;
  bool _isLoading = false,
      _isHighlighted = false,
      _isDataLoaded = false,
      _isPublishing = false;
  List<Organization> orgs = [];
  List<Catalog> catalogs = [];
  List<ProductInfo> productsInfos = [];

  final _message = 'Drop products here';
  final _searchController = TextEditingController();
  SortType sortType = SortType.recent;

  late final _selectAllButton = Checkbox(
      checked: true, onChanged: (value) => changeSelectionCallback(false));
  late final _clearAllButton = Checkbox(
      checked: false, onChanged: (value) => changeSelectionCallback(true));
  late final _selectedButton = Checkbox(
      checked: null, onChanged: (value) => changeSelectionCallback(false));

  void changeSelectionCallback(bool? state) {
    if (state == false) {
      productsSelected = 0;
    } else if (state = true) {
      productsSelected = productsInfos.length;
    }
    setState(
      () {
        for (var product in productsInfos) {
          product.isSelected = state ?? product.isSelected;
        }
      },
    );
  }

  void _clearData() {
    orgs = [];
    catalogs = [];
  }

  bool _areDataAvailable() {
    return orgs.isNotEmpty && catalogs.isNotEmpty;
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    _clearData();
    orgs = await OrganizationsService.getInstance().listOrgs(widget.environment,
        queryParameters: "fields=name&fields=title&fields=owner_url");
    if (orgs.isEmpty || _organizationIndex >= orgs.length) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        widget.environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty || _catalogIndex >= catalogs.length) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadDataLogic() async {
    orgs = await OrganizationsService.getInstance().listOrgs(widget.environment,
        queryParameters: "fields=name&fields=title&fields=owner_url");
    if (orgs.isEmpty) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        widget.environment, orgs[0].name!,
        queryParameters: "fields=name&fields=title");
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadDataLogic();
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _applyOrganizationChanges() async {
    _catalogIndex = 0;
    catalogs = await CatalogsService.getInstance().listCatalogs(
        widget.environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty) return;
  }

  void _applyChange(ChangeType changeType) async {
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
  }

  List<ComboBoxItem<int>> _buildOrgsMenu() {
    List<ComboBoxItem<int>> orgsMenu = [];
    for (int i = 0; i < orgs.length; i++) {
      orgsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          orgs[i].title!,
        ),
      ));
    }
    return orgsMenu;
  }

  List<ComboBoxItem<int>> _buildCatalogsMenu() {
    List<ComboBoxItem<int>> catalogsMenu = [];
    for (int i = 0; i < catalogs.length; i++) {
      catalogsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          catalogs[i].title!,
        ),
      ));
    }
    return catalogsMenu;
  }

  Widget buildSGlobalSelectionButton() {
    if (productsSelected == productsInfos.length) {
      return _selectAllButton;
    } else if (productsSelected == 0) {
      return _clearAllButton;
    }
    return _selectedButton;
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

        String openAPIFilename = basename(openAPIPath);
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return _isLoading
        ? const Loader()
        : Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text("Organization: "),
                        ComboBox<int>(
                          value: _organizationIndex,
                          items: _buildOrgsMenu(),
                          onChanged: (index) => setState(() {
                            _organizationIndex = index!;
                            _applyChange(ChangeType.organization);
                          }),
                        ),
                        const SizedBox(width: 10),
                        const Text("Catalog: "),
                        ComboBox<int>(
                          value: _catalogIndex,
                          items: _buildCatalogsMenu(),
                          onChanged: (index) => setState(() {
                            _catalogIndex = index!;
                            _applyChange(ChangeType.catalog);
                          }),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Button(
                          style: ButtonStyle(
                            padding: ButtonState.all(const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 25)),
                          ),
                          child: const Text('Publish'),
                          onPressed: () async {},
                        ),
                        const SizedBox(width: 10),
                        Button(
                          style: ButtonStyle(
                            padding: ButtonState.all(const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 25)),
                          ),
                          child: const Text('Subscribe'),
                          onPressed: () async {},
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(FluentIcons.refresh),
                          onPressed: () => _refreshData(),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 15),
                !_isDataLoaded
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: _isHighlighted
                                  ? Colors.grey[40]
                                  : Colors.grey[100],
                            ),
                            width: screenWidth * 0.95,
                            height: screenHeight * 0.65,
                            child: Stack(
                              children: [
                                DropTarget(
                                  onDragDone: (detail) async {
                                    try {
                                      setState(() => _isLoading = true);
                                      for (final file in detail.files) {
                                        if (await FileSystemEntity.isDirectory(
                                            file.path)) {
                                        } else if (RegExp("^.*.(yaml|yml)\$")
                                            .hasMatch(
                                                file.name.toLowerCase())) {
                                          // Publish product
                                          await addProduct(file);
                                        }
                                      }
                                      if (productsInfos.isNotEmpty) {
                                        _isDataLoaded = true;
                                      } else {
                                        ErrorHandlingUtilities.instance
                                            .showPopUpError(
                                                "No valid yaml-based product file has been found");
                                      }
                                      setState(() => _isLoading = false);
                                    } catch (error, stackTrace) {
                                      Logger().e(
                                          "ProductsSubScreen:DragAndDrop",
                                          error,
                                          stackTrace);
                                      ErrorHandlingUtilities.instance
                                          .showPopUpError(error.toString());
                                    }
                                  },
                                  onDragEntered: (details) =>
                                      setState(() => _isHighlighted = true),
                                  onDragExited: (details) =>
                                      setState(() => _isHighlighted = false),
                                  child: Container(),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(FluentIcons.bulk_upload,
                                          size: 80, color: Colors.white),
                                      Text(
                                        _message,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Button(
                                style: ButtonStyle(
                                  padding: ButtonState.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 25)),
                                ),
                                child: const Text('Pick Files'),
                                onPressed: () async {},
                              ),
                              const SizedBox(width: 25),
                              const Text("OR"),
                              const SizedBox(width: 25),
                              Button(
                                style: ButtonStyle(
                                  padding: ButtonState.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 25)),
                                ),
                                child: const Text('Pick Folder'),
                                onPressed: () async {},
                              ),
                            ],
                          )
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              buildSGlobalSelectionButton(),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextBox(
                                  controller: _searchController,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ComboBox<SortType>(
                                items: const [
                                  ComboBoxItem(
                                    value: SortType.ascending,
                                    child: Text("Ascending"),
                                  ),
                                  ComboBoxItem(
                                    value: SortType.descending,
                                    child: Text("Descending"),
                                  ),
                                  ComboBoxItem(
                                    value: SortType.recent,
                                    child: Text("Recent"),
                                  )
                                ],
                                icon: const Icon(FluentIcons.sort),
                                iconSize: 15,
                                onChanged: ((value) {
                                  setState(() {
                                    sortType = value!;
                                  });
                                }),
                                value: sortType,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                              width: screenWidth,
                              height: 450,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.black.withOpacity(0.2),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              child: _isPublishing
                                  ? const Loader()
                                  : ListView.builder(
                                      itemCount: productsInfos.length,
                                      itemBuilder: (ctx, index) {
                                        return ListTile(
                                          tileColor:
                                              ButtonState.all(Colors.grey),
                                          leading: Checkbox(
                                            onChanged: (isChecked) =>
                                                setState(() {
                                              productsInfos[index].isSelected =
                                                  isChecked ?? false;
                                              productsSelected +=
                                                  (isChecked ?? false) ? 1 : -1;
                                            }),
                                            checked:
                                                productsInfos[index].isSelected,
                                          ),
                                          title: Text(
                                              productsInfos[index]
                                                      .adaptor
                                                      .info
                                                      .title ??
                                                  productsInfos[index]
                                                      .adaptor
                                                      .info
                                                      .name,
                                              textScaleFactor: 1),
                                          subtitle: Text(productsInfos[index]
                                              .adaptor
                                              .info
                                              .version),
                                          trailing: Row(
                                            children: [
                                              Button(
                                                  child: const Text("Publish"),
                                                  onPressed: () async {
                                                    final isConfirmed =
                                                        await showDialog<bool>(
                                                              barrierDismissible:
                                                                  true,
                                                              context: context,
                                                              builder: (ctx) {
                                                                return ConfirmationPopUp(
                                                                    "Do you want to publish ${productsInfos[index].adaptor.info.name}:${productsInfos[index].adaptor.info.version}");
                                                              },
                                                            ) ??
                                                            false;
                                                    setState(() =>
                                                        _isPublishing = true);
                                                    if (isConfirmed) {
                                                      await ProductService.getInstance()
                                                          .publish(
                                                              widget
                                                                  .environment,
                                                              orgs[_organizationIndex]
                                                                  .name!,
                                                              catalogs[
                                                                      _catalogIndex]
                                                                  .name,
                                                              productsInfos[
                                                                  index]);
                                                    }
                                                    setState(() =>
                                                        _isPublishing = false);
                                                  }),
                                              const SizedBox(width: 10),
                                              Button(
                                                child: const Text("Subscribe"),
                                                onPressed: () {},
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    )),
                        ],
                      )
              ],
            ),
          );
  }
}
