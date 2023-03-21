import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
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
  int _organizationIndex = 0, _catalogIndex = 0;
  bool _isLoading = false, _isHighlighted = false;
  bool _isDataLoaded = false;
  List<Organization> orgs = [];
  List<Catalog> catalogs = [];
  List<Product> products = [];

  final String _message = 'Drop products here';

  final _searchController = TextEditingController();
  SortType sortType = SortType.recent;

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
    if (catalogs.isEmpty) return;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadDataLogic();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData().then((value) => null);
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
                                        print(file.path);
                                        if (await FileSystemEntity.isDirectory(
                                            file.path)) {
                                        } else if (RegExp("^.*.(yaml|yml)\$")
                                            .hasMatch(
                                                file.name.toLowerCase())) {
                                          try {
                                            String fileAsString =
                                                await File(file.path)
                                                    .readAsString();
                                            var doc = loadYaml(fileAsString);
                                            var jsonString =
                                                jsonDecode(json.encode(doc));
                                            var product =
                                                Product.fromJson(jsonString);

                                            products.add(product);
                                            print(product.info.name);
                                          } catch (e) {}
                                        }
                                      }
                                      if (products.isNotEmpty) {
                                        setState(() {
                                          _isLoading = false;
                                          _isDataLoaded = true;
                                        });
                                      } else {
                                        ErrorHandlingUtilities.instance
                                            .showPopUpError(
                                                "No valid yaml-based product file has been found");
                                      }
                                      // product.apis.forEach((key, value) async {
                                      //   String filePath = path.join(
                                      //       path.dirname(
                                      //           detail.files.single.path),
                                      //       value.ref.replaceAll("/", "\\"));
                                      //   print(filePath);
                                      //   // print(await File(filePath).readAsString());
                                      // });
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
                              child: ListView.builder(
                                itemCount: products.length,
                                itemBuilder: (ctx, index) {
                                  return ListTile(
                                    title: Text(
                                        products[index].info.title ??
                                            products[index].info.name,
                                        textScaleFactor: 1.1),
                                    subtitle:
                                        Text(products[index].info.version),
                                    trailing: Row(
                                      children: [
                                        Button(
                                            child: const Text("Publish"),
                                            onPressed: () {}),
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
