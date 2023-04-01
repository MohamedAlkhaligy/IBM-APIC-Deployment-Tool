import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

import './upload_products_screen.dart';
import '../controllers/products_controller.dart';
import '../global_configurations.dart';
import '../models/environment.dart';
import '../widgets/confirmation_pop_up.dart';
import '../widgets/loader.dart';
import '../widgets/responsive_text.dart';

class ProductsSubScreen extends StatefulWidget {
  final Environment environment;

  const ProductsSubScreen(this.environment, {super.key});

  @override
  State<ProductsSubScreen> createState() => _ProductsSubScreenState();
}

class _PublishConfirmation {
  bool confirmAction;
  bool migrateSubscribtions;
  _PublishConfirmation()
      : confirmAction = false,
        migrateSubscribtions = true;
}

class _ProductsSubScreenState extends State<ProductsSubScreen> {
  final _searchController = TextEditingController();

  bool _isLoading = false, _areFilesLoaded = false, _isPublishing = false;
  Color color = Colors.white;
  SortType sortType = SortType.ascending;

  late final ProductController _productController;
  late final _selectAllButton = Checkbox(
      checked: true, onChanged: (value) => changeSelectionCallback(false));
  late final _clearAllButton = Checkbox(
      checked: false, onChanged: (value) => changeSelectionCallback(true));
  late final _selectedButton = Checkbox(
      checked: null, onChanged: (value) => changeSelectionCallback(false));

  Widget _buildSGlobalSelectionButton() {
    if (_productController.productsSelected ==
            _productController.productsInfos.length &&
        _productController.productsInfos.isNotEmpty) {
      return _selectAllButton;
    } else if (_productController.productsSelected == 0) {
      return _clearAllButton;
    }
    return _selectedButton;
  }

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

  Widget _buildButton({
    required Widget icon,
    required String confirmationText,
    required Function onConfirmedFunction,
    String? tooltipMessage,
  }) {
    return Tooltip(
      message: tooltipMessage ?? '',
      child: IconButton(
        icon: icon,
        onPressed: () async {
          final isConfirmed = await showDialog<bool>(
                barrierDismissible: true,
                context: context,
                builder: (ctx) {
                  return ConfirmationPopUp(confirmationText);
                },
              ) ??
              false;
          if (isConfirmed) {
            onConfirmedFunction();
          }
        },
      ),
    );
  }

  Widget _buildGlobalButtons() {
    return Row(
      children: [
        _buildButton(
          icon: const Icon(FluentIcons.remove_from_shopping_list),
          tooltipMessage: "Unload products",
          confirmationText: "Do you wish to unload all products?",
          onConfirmedFunction: () {
            setState(() => _isLoading = true);
            _productController.unLoadProducts();
            _areFilesLoaded = false;
            changeSelectionCallback(false);
            setState(() => _isLoading = false);
          },
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: "Publish selected products",
          child: IconButton(
              icon: const Icon(FluentIcons.publish_content),
              onPressed: () async {
                final confirmation = await openPublishConfirmationDialog(
                  "Do you want to publish the selected products?",
                );
                if (confirmation != null && confirmation.confirmAction) {
                  setState(() => _isPublishing = true);
                  await _productController.publishSelected(
                      migrateSubscriptions: confirmation.migrateSubscribtions);
                  setState(() => _isPublishing = false);
                }
              }),
        ),
        // const SizedBox(width: 10),
        // Tooltip(
        //   message: "Subscribe selected products",
        //   child: IconButton(
        //     icon: Image.asset("assets/icons/subscription-64.png", width: 16),
        //     onPressed: null,
        //   ),
        // ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(FluentIcons.refresh),
          onPressed: () => _refreshData(),
        )
      ],
    );
  }

  Future<_PublishConfirmation?> openPublishConfirmationDialog(
          String confirmationText) async =>
      await showDialog<_PublishConfirmation>(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          _PublishConfirmation confirmation = _PublishConfirmation();
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: material.AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              title: Text(confirmationText),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Checkbox(
                        content: const Text('Migrate Subscriptions'),
                        checked: confirmation.migrateSubscribtions,
                        onChanged: (bool? value) => setState(
                            () => confirmation.migrateSubscribtions = value!),
                      ),
                    ],
                  );
                },
              ),
              actionsAlignment: MainAxisAlignment.end,
              actionsPadding: const EdgeInsets.all(10),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    confirmation.confirmAction = true;
                    Navigator.of(context).pop(confirmation);
                  },
                  child: const Text(
                    'Yes',
                    textScaleFactor: 1.5,
                  ),
                ),
                const SizedBox(width: 25),
                TextButton(
                  child: const Text(
                    'No',
                    textScaleFactor: 1.5,
                  ),
                  onPressed: () {
                    confirmation.confirmAction = false;
                    Navigator.of(context).pop(confirmation);
                  },
                ),
              ],
            ),
          );
        },
      );

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
                    const SizedBox(width: 10),
                    if (_productController.productsInfos.isNotEmpty)
                      _buildGlobalButtons(),
                    if (_productController.productsInfos.isEmpty)
                      IconButton(
                        icon: const Icon(FluentIcons.refresh),
                        onPressed: () => _refreshData(),
                      )
                  ],
                ),
                const SizedBox(height: 15),
                !_areFilesLoaded
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: Colors.black.withOpacity(0.2),
                        ),
                        width: screenWidth,
                        height: screenHeight * 0.7,
                        child: Center(
                          child: MouseRegion(
                            onHover: (event) =>
                                setState(() => color = Colors.grey),
                            onExit: (event) =>
                                setState(() => color = Colors.white),
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                setState(() => _isLoading = true);
                                _areFilesLoaded = await showDialog<bool>(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (ctx) {
                                        return UploadProductsScreen(
                                          _productController,
                                        );
                                      },
                                    ) ??
                                    false;
                                setState(() => _isLoading = false);
                              },
                              child: SizedBox(
                                width: screenWidth / 2,
                                height: screenHeight * 0.7 / 2,
                                child: DottedBorder(
                                  color: color,
                                  radius: const Radius.circular(15),
                                  strokeWidth: 2,
                                  dashPattern: const [10, 10],
                                  borderType: BorderType.RRect,
                                  child: Center(
                                    child: Icon(
                                      FluentIcons.add,
                                      size: 45,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                                  onChanged: (value) {
                                    _productController.searchProduct(value);
                                    changeSelectionCallback(false);
                                    setState(() {});
                                  },
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
                                  )
                                ],
                                icon: const Icon(FluentIcons.sort),
                                iconSize: 15,
                                onChanged: ((value) {
                                  setState(() {
                                    sortType = value!;
                                    _productController.sort(sortType);
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
                                    itemCount:
                                        _productController.productsInfos.length,
                                    itemBuilder: (ctx, index) {
                                      return ListTile(
                                        tileColor: ButtonState.all(Colors.grey),
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
                                              .productsInfos[index].isSelected,
                                        ),
                                        title: Text(
                                          _productController
                                              .productsInfos[index].title,
                                          textScaleFactor: 1,
                                        ),
                                        subtitle: Text(
                                          _productController
                                              .productsInfos[index].version,
                                        ),
                                        trailing: Row(
                                          children: [
                                            Tooltip(
                                              message: "Publish Product",
                                              child: IconButton(
                                                  icon: const Icon(
                                                      FluentIcons
                                                          .publish_content,
                                                      size: 18),
                                                  onPressed: () async {
                                                    final confirmation =
                                                        await openPublishConfirmationDialog(
                                                      "Do you want to publish ${_productController.productsInfos[index].name}:${_productController.productsInfos[index].version} to ${_productController.catalogs[_productController.catalogIndex].name}",
                                                    );
                                                    if (confirmation != null &&
                                                        confirmation
                                                            .confirmAction) {
                                                      setState(() =>
                                                          _isPublishing = true);
                                                      await _productController.publish(
                                                          index,
                                                          migrateSubscriptions:
                                                              confirmation
                                                                  .migrateSubscribtions);
                                                      setState(() =>
                                                          _isPublishing =
                                                              false);
                                                    }
                                                  }),
                                            ),
                                            // const SizedBox(width: 10),
                                            // const Button(
                                            //   onPressed: null,
                                            //   child: Text("Subscribe"),
                                            // ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      )
              ],
            ),
          );
  }
}
