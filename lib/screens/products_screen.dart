import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

import 'products_manage_screen.dart';
import 'products_publish_screen.dart';
import '../models/environment.dart';

class ProductsScreen extends StatefulWidget {
  final Environment environment;

  const ProductsScreen(this.environment, {super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

enum ProductAction { publish, manage }

class _ProductActionTabMeta {
  Widget screen;
  Widget icon;

  _ProductActionTabMeta(this.screen, this.icon);
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _currentIndex = 0;
  int _counter = 0;
  final List<Tab> _tabs = [];
  ProductAction action = ProductAction.publish;

  List<ComboBoxItem<ProductAction>> actions = const [
    ComboBoxItem(value: ProductAction.publish, child: Text("Publish")),
    ComboBoxItem(value: ProductAction.manage, child: Text("Manage")),
  ];

  Future<String?> openDialog() async {
    return await showDialog<String>(
      barrierDismissible: true,
      context: context,
      builder: (ctx) {
        TextEditingController controller =
            TextEditingController(text: 'Tab $_counter');
        return material.AlertDialog(
          title: const Text("Enter Tab Title"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextBox(
                    controller: controller,
                    onEditingComplete: () =>
                        Navigator.of(context).pop(controller.text),
                    autofocus: true,
                  ),
                  const SizedBox(height: 10),
                  ComboBox<ProductAction>(
                    isExpanded: true,
                    value: action,
                    items: actions,
                    onChanged: (selectedAction) => setState(() {
                      if (selectedAction != null) {
                        action = selectedAction;
                      }
                    }),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );
  }

  _ProductActionTabMeta getTabMeta(ProductAction selectedAction) {
    switch (selectedAction) {
      case ProductAction.publish:
        return _ProductActionTabMeta(
            ProductsPublishScreen(widget.environment),
            Icon(
              FluentIcons.publish_content,
              color: Colors.green.light,
            ));
      case ProductAction.manage:
        return _ProductActionTabMeta(
            ProductsManageScreen(widget.environment),
            Icon(
              FluentIcons.task_manager,
              color: Colors.blue.light,
            ));
    }
  }

  Future<Tab?> generateTab(Key key) async {
    Tab? tab;
    String? tabName = await openDialog();
    if (tabName != null && tabName.isNotEmpty) {
      _ProductActionTabMeta tabMeta = getTabMeta(action);
      tab = Tab(
        text: Text(tabName),
        key: key,
        semanticLabel: 'Tab #${_counter++}',
        icon: tabMeta.icon,
        body: SingleChildScrollView(
          key: key,
          child: tabMeta.screen,
        ),
        onClosed: () {
          setState(() {
            Key viewedTabKey = _tabs[_currentIndex].key!;
            int closedTabIndex = _tabs.indexWhere((tab) => tab.key == key);
            _tabs.removeWhere((tab) => tab.key == key);
            if (_currentIndex != closedTabIndex) {
              _currentIndex =
                  _tabs.indexWhere((tab) => tab.key == viewedTabKey);
            } else {
              if (_currentIndex > 0) _currentIndex--;
            }
            if (_tabs.isEmpty) {
              _counter = 0;
            }
          });
        },
      );
    }
    return tab;
  }

  @override
  Widget build(BuildContext context) {
    return TabView(
      tabs: _tabs,
      currentIndex: _currentIndex,
      onChanged: (index) => setState(() => _currentIndex = index),
      tabWidthBehavior: TabWidthBehavior.equal,
      closeButtonVisibility: CloseButtonVisibilityMode.always,
      showScrollButtons: true,
      wheelScroll: false,
      onNewPressed: () async {
        final tab = await generateTab(UniqueKey());
        if (tab != null) {
          _tabs.add(tab);
          _currentIndex = _tabs.length - 1;
        }
        setState(() {});
      },
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final item = _tabs.removeAt(oldIndex);
          _tabs.insert(newIndex, item);

          if (_currentIndex == newIndex) {
            _currentIndex = oldIndex;
          } else if (_currentIndex == oldIndex) {
            _currentIndex = newIndex;
          }
        });
      },
    );
  }
}
