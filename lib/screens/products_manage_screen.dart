import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:ibm_apic_dt/global_configurations.dart';

import '../models/environment.dart';
import '../widgets/loader.dart';
import '../controllers/products_manage_controller.dart';
import '../widgets/responsive_text.dart';

class ProductsManageScreen extends StatefulWidget {
  final Environment environment;

  const ProductsManageScreen(this.environment, {super.key});

  @override
  State<ProductsManageScreen> createState() => _ProductsManageScreenState();
}

class _ProductsManageScreenState extends State<ProductsManageScreen> {
  final _searchController = TextEditingController();

  bool _isLoading = false;
  SortType sortType = SortType.none;

  late final ProductsManageController _productsManageController;
  late final _selectAllButton = Checkbox(
      checked: true, onChanged: (value) => changeSelectionCallback(false));
  late final _clearAllButton = Checkbox(
      checked: false, onChanged: (value) => changeSelectionCallback(true));
  late final _selectedButton = Checkbox(
      checked: null, onChanged: (value) => changeSelectionCallback(false));

  @override
  void initState() {
    super.initState();
    _productsManageController = ProductsManageController(widget.environment);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _productsManageController.loadData();
    setState(() => _isLoading = false);
  }

  void changeSelectionCallback(bool? state) {
    if (state == false) {
      _productsManageController.productsSelected = 0;
    } else if (state = true) {
      _productsManageController.productsSelected =
          _productsManageController.products.length;
    }
    setState(
      () {
        for (var product in _productsManageController.products) {
          product.isSelected = state ?? product.isSelected;
        }
      },
    );
  }

  List<ComboBoxItem<int>> _buildOrgsMenu() {
    List<ComboBoxItem<int>> orgsMenu = [];
    for (int i = 0; i < _productsManageController.orgs.length; i++) {
      orgsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          _productsManageController.orgs[i].title!,
        ),
      ));
    }
    return orgsMenu;
  }

  List<ComboBoxItem<int>> _buildCatalogsMenu() {
    List<ComboBoxItem<int>> catalogsMenu = [];
    for (int i = 0; i < _productsManageController.catalogs.length; i++) {
      catalogsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          _productsManageController.catalogs[i].title!,
        ),
      ));
    }
    return catalogsMenu;
  }

  void _applyChange(ChangeType changeType) async {
    setState(() => _isLoading = true);
    await _productsManageController.applyChange(changeType);
    sortType = SortType.none;
    setState(() => _isLoading = false);
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _productsManageController.refreshData();
    _productsManageController.sort(sortType);
    setState(() => _isLoading = false);
  }

  Future<void> _changeLimit(int limit) async {
    setState(() => _isLoading = true);
    await _productsManageController.changeLimit(limit);
    sortType = SortType.none;
    setState(() => _isLoading = false);
  }

  Future<void> _changePageNumber(int pageNUmber) async {
    setState(() => _isLoading = true);
    await _productsManageController.changePageNumber(pageNUmber);
    sortType = SortType.none;
    setState(() => _isLoading = false);
  }

  Widget _buildSGlobalSelectionButton() {
    if (_productsManageController.productsSelected ==
            _productsManageController.products.length &&
        _productsManageController.products.isNotEmpty) {
      return _selectAllButton;
    } else if (_productsManageController.productsSelected == 0) {
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
                          value: _productsManageController.organizationIndex,
                          items: _buildOrgsMenu(),
                          onChanged: (index) => setState(() {
                            _productsManageController.organizationIndex =
                                index!;
                            _applyChange(ChangeType.organization);
                          }),
                        ),
                        const SizedBox(width: 10),
                        const Text("Catalog: "),
                        ComboBox<int>(
                          value: _productsManageController.catalogIndex,
                          items: _buildCatalogsMenu(),
                          onChanged: (index) => setState(() {
                            _productsManageController.catalogIndex = index!;
                            _applyChange(ChangeType.catalog);
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(FluentIcons.refresh),
                      onPressed: () => _refreshData(),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Column(
                  children: [
                    Row(
                      children: [
                        _buildSGlobalSelectionButton(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextBox(
                            enabled: false,
                            placeholder:
                                "Searching & Sorting will be available by next update!",
                            controller: _searchController,
                            onChanged: (value) {
                              _productsManageController.searchProduct(value);
                              changeSelectionCallback(false);
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        ComboBox<SortType>(
                          items: const [
                            ComboBoxItem(
                              value: SortType.none,
                              child: Text("None"),
                            ),
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
                          // onChanged: ((value) {
                          //   setState(() {
                          //     sortType = value!;
                          //     _productsManageController.sort(sortType);
                          //   });
                          // }),
                          value: sortType,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: screenWidth,
                      height: 420,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black.withOpacity(0.2),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: ListView.builder(
                        itemCount: _productsManageController.products.length,
                        itemBuilder: (ctx, productIndex) {
                          final product =
                              _productsManageController.products[productIndex];
                          Duration diff = DateTime.now()
                              .difference(DateTime.parse(product.updatedAt));
                          String lastUpdatedAt =
                              timeago.format(DateTime.now().subtract(diff));
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 2),
                            child: Expander(
                              headerHeight: 55,
                              header: ListTile(
                                leading: Checkbox(
                                  onChanged: (isChecked) => setState(() {
                                    product.isSelected = isChecked ?? false;
                                    _productsManageController
                                            .productsSelected +=
                                        (isChecked ?? false) ? 1 : -1;
                                  }),
                                  checked: product.isSelected,
                                ),
                                tileColor: ButtonState.all(
                                    Colors.black.withOpacity(0.4)),
                                title: Text(product.title),
                                subtitle: SelectableText(
                                    "${product.name}:${product.version} - ${product.state} - ${max(product.plans.length - 1, 0)} Plans - $lastUpdatedAt"),
                                trailing: Row(
                                  children: [
                                    // Tooltip(
                                    //   message: "View Product",
                                    //   child: IconButton(
                                    //     icon: const Icon(FluentIcons.view),
                                    //     onPressed: () async {},
                                    //   ),
                                    // ),
                                    // const SizedBox(width: 10),
                                    // Tooltip(
                                    //   message: "Download Product",
                                    //   child: IconButton(
                                    //     icon: const Icon(FluentIcons.download),
                                    //     onPressed: () async {},
                                    //   ),
                                    // ),
                                    // const SizedBox(width: 10),
                                    // Tooltip(
                                    //   message: "Delete Product",
                                    //   child: IconButton(
                                    //     icon: const Icon(FluentIcons.delete),
                                    //     onPressed: () async {
                                    //       final isConfirmed =
                                    //           await showDialog<bool>(
                                    //                 barrierDismissible: true,
                                    //                 context: context,
                                    //                 builder: (ctx) {
                                    //                   return const Text("");
                                    //                 },
                                    //               ) ??
                                    //               false;
                                    //       if (isConfirmed) {
                                    //         setState(() => _isLoading = false);
                                    //       }
                                    //     },
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text("APIs per Plan: "),
                                      ComboBox<String>(
                                        value: product.selectedPlan,
                                        items: product.plans.entries
                                            .map((entry) =>
                                                ComboBoxItem<String>(
                                                  value: entry.key,
                                                  child:
                                                      Text(entry.value.title),
                                                ))
                                            .toList(),
                                        onChanged: (planName) {
                                          if (planName != null) {
                                            setState(() => product
                                                .selectedPlan = planName);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 150,
                                    child: ListView.builder(
                                      itemCount: product
                                          .plans[product.selectedPlan]!
                                          .apis
                                          .length,
                                      itemBuilder: (ctx, apiIndex) {
                                        final api = product
                                            .plans[product.selectedPlan]!
                                            .apis[apiIndex];
                                        return ListTile(
                                          tileColor: ButtonState.all(
                                              Colors.black.withOpacity(0.4)),
                                          title: Text(api.title),
                                          subtitle: SelectableText(
                                            "${api.name}:${api.version}",
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_productsManageController.products.isNotEmpty)
                      Container(
                        width: screenWidth,
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black.withOpacity(0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("Catalog Products per page"),
                                const SizedBox(width: 10),
                                ComboBox<int>(
                                  value: _productsManageController.limit,
                                  items: [10, 25, 50, 100]
                                      .map((pageSize) => ComboBoxItem<int>(
                                          value: pageSize,
                                          child: Text(pageSize.toString())))
                                      .toList(),
                                  onChanged: (pageSize) {
                                    if (pageSize != null) {
                                      _changeLimit(pageSize);
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                Text(
                                    "${_productsManageController.offset + 1}-${min(_productsManageController.offset + _productsManageController.limit, _productsManageController.totalCatalogProducts)} of ${_productsManageController.totalCatalogProducts} Catalog Products")
                              ],
                            ),
                            Row(
                              children: [
                                ComboBox<int>(
                                  value: _productsManageController.pageNumber,
                                  items: [
                                    for (var i = 1;
                                        i <=
                                            _productsManageController
                                                .numberOfPages;
                                        i++)
                                      i
                                  ]
                                      .map((pageSize) => ComboBoxItem<int>(
                                          value: pageSize,
                                          child: Text(pageSize.toString())))
                                      .toList(),
                                  onChanged: (pageNumber) {
                                    if (pageNumber != null) {
                                      _changePageNumber(pageNumber);
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                Text(
                                    "${_productsManageController.pageNumber} of ${_productsManageController.numberOfPages} pages"),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon:
                                      const Icon(FluentIcons.caret_left_solid8),
                                  onPressed:
                                      _productsManageController.pageNumber == 1
                                          ? null
                                          : () => _changePageNumber(
                                              _productsManageController
                                                      .pageNumber -
                                                  1),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                      FluentIcons.caret_right_solid8),
                                  onPressed: _productsManageController
                                              .pageNumber ==
                                          _productsManageController
                                              .numberOfPages
                                      ? null
                                      : () => _changePageNumber(
                                          _productsManageController.pageNumber +
                                              1),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                  ],
                )
              ],
            ),
          );
  }
}
