import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/utilities/error_handling_utilities.dart';

import '../controllers/products_controller.dart';
import '../models/environment.dart';
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
  bool _isLoading = false,
      _areFilesLoaded = false,
      _isHighlighted = false,
      _isPublishing = false;
  final _message = 'Drop products here';
  final _searchController = TextEditingController();
  late final ProductController _productController;
  SortType sortType = SortType.recent;

  late final _selectAllButton = Checkbox(
      checked: true, onChanged: (value) => changeSelectionCallback(false));
  late final _clearAllButton = Checkbox(
      checked: false, onChanged: (value) => changeSelectionCallback(true));
  late final _selectedButton = Checkbox(
      checked: null, onChanged: (value) => changeSelectionCallback(false));

  void changeSelectionCallback(bool? state) {
    if (state == false) {
      _productController.productsSelected = 0;
    } else if (state = true) {
      _productController.productsSelected =
          _productController.productsInfos.length;
    }
    setState(
      () {
        for (var product in _productController.productsInfos) {
          product.isSelected = state ?? product.isSelected;
        }
      },
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _productController.refreshData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _productController.loadData();
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _productController = ProductController(widget.environment);
    _loadData();
  }

  void _applyChange(ChangeType changeType) async {
    setState(() {
      _isLoading = true;
    });
    await _productController.applyChange(ChangeType.catalog);
    setState(() {
      _isLoading = false;
    });
  }

  List<ComboBoxItem<int>> _buildOrgsMenu() {
    List<ComboBoxItem<int>> orgsMenu = [];
    for (int i = 0; i < _productController.orgs.length; i++) {
      orgsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          _productController.orgs[i].title!,
        ),
      ));
    }
    return orgsMenu;
  }

  List<ComboBoxItem<int>> _buildCatalogsMenu() {
    List<ComboBoxItem<int>> catalogsMenu = [];
    for (int i = 0; i < _productController.catalogs.length; i++) {
      catalogsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          _productController.catalogs[i].title!,
        ),
      ));
    }
    return catalogsMenu;
  }

  Widget _buildSGlobalSelectionButton() {
    if (_productController.productsSelected ==
        _productController.productsInfos.length) {
      return _selectAllButton;
    } else if (_productController.productsSelected == 0) {
      return _clearAllButton;
    }
    return _selectedButton;
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
                          value: _productController.organizationIndex,
                          items: _buildOrgsMenu(),
                          onChanged: (index) => setState(() {
                            _productController.organizationIndex = index!;
                            _applyChange(ChangeType.organization);
                          }),
                        ),
                        const SizedBox(width: 10),
                        const Text("Catalog: "),
                        ComboBox<int>(
                          value: _productController.catalogIndex,
                          items: _buildCatalogsMenu(),
                          onChanged: (index) => setState(() {
                            _productController.catalogIndex = index!;
                            _applyChange(ChangeType.catalog);
                          }),
                        ),
                      ],
                    ),
                    if (_productController.productsInfos.isNotEmpty)
                      Row(
                        children: [
                          Button(
                            style: ButtonStyle(
                              padding: ButtonState.all(
                                  const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 25)),
                            ),
                            child: const Text('Publish'),
                            onPressed: () async {
                              final isConfirmed = await showDialog<bool>(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (ctx) {
                                      return const ConfirmationPopUp(
                                          "Do you want to publish the selected products?");
                                    },
                                  ) ??
                                  false;
                              if (isConfirmed) {
                                setState(() => _isPublishing = true);
                                await _productController.publishSelected();
                                setState(() => _isPublishing = false);
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          Button(
                            style: ButtonStyle(
                              padding: ButtonState.all(
                                  const EdgeInsets.symmetric(
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
                !_areFilesLoaded
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
                                  key: UniqueKey(),
                                  onDragDone: (detail) async {
                                    setState(() => _isLoading = true);
                                    _areFilesLoaded = await _productController
                                        .loadProducts(detail.files);
                                    setState(() => _isLoading = false);
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
                              _buildSGlobalSelectionButton(),
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
                                      itemCount: _productController
                                          .productsInfos.length,
                                      itemBuilder: (ctx, index) {
                                        return ListTile(
                                          tileColor:
                                              ButtonState.all(Colors.grey),
                                          leading: Checkbox(
                                            onChanged: (isChecked) =>
                                                setState(() {
                                              _productController
                                                      .productsInfos[index]
                                                      .isSelected =
                                                  isChecked ?? false;
                                              _productController
                                                      .productsSelected +=
                                                  (isChecked ?? false) ? 1 : -1;
                                            }),
                                            checked: _productController
                                                .productsInfos[index]
                                                .isSelected,
                                          ),
                                          title: Text(
                                              _productController
                                                      .productsInfos[index]
                                                      .adaptor
                                                      .info
                                                      .title ??
                                                  _productController
                                                      .productsInfos[index]
                                                      .adaptor
                                                      .info
                                                      .name,
                                              textScaleFactor: 1),
                                          subtitle: Text(_productController
                                              .productsInfos[index]
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
                                                                    "Do you want to publish ${_productController.productsInfos[index].adaptor.info.name}:${_productController.productsInfos[index].adaptor.info.version}");
                                                              },
                                                            ) ??
                                                            false;
                                                    setState(() =>
                                                        _isPublishing = true);
                                                    if (isConfirmed) {
                                                      await _productController
                                                          .publish(index);
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
