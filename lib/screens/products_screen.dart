import 'package:fluent_ui/fluent_ui.dart';

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
  List<Tab> _tabs = [];

  Tab generateTab(Key key) {
    late Tab tab;
    tab = Tab(
      text: Text('Tab $_counter'),
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
            _currentIndex = _tabs.indexWhere((tab) => tab.key == viewedTabKey);
          } else {
            if (_currentIndex > 0) _currentIndex--;
          }
          if (_tabs.isEmpty) {
            _counter = 0;
          }
        });
      },
    );
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
      onNewPressed: () {
        setState(() {
          final tab = generateTab(UniqueKey());
          _tabs.add(tab);
        });
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
