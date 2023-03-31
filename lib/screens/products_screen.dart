import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

import './products_subscreen.dart';
import '../models/environment.dart';

class ProductsScreen extends StatefulWidget {
  final Environment environment;

  const ProductsScreen(this.environment, {super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _currentIndex = 0;
  int _counter = 0;
  final List<Tab> _tabs = [];

  Future<String?> openDialog() async => await showDialog<String>(
        barrierDismissible: true,
        context: context,
        builder: (ctx) {
          TextEditingController controller =
              TextEditingController(text: 'Tab $_counter');
          return material.AlertDialog(
            title: const Text("Enter Tab Title"),
            content: TextBox(
              controller: controller,
              onEditingComplete: () =>
                  Navigator.of(context).pop(controller.text),
              autofocus: true,
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

  Future<Tab?> generateTab(Key key) async {
    Tab? tab;
    String? tabName = await openDialog();
    if (tabName != null && tabName.isNotEmpty) {
      tab = Tab(
        text: Text(tabName),
        key: key,
        semanticLabel: 'Tab #${_counter++}',
        icon: const FlutterLogo(),
        body: SingleChildScrollView(
          key: key,
          child: ProductsSubScreen(widget.environment),
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
