import 'package:fluent_ui/fluent_ui.dart';

import '../models/environment.dart';
import 'global_policies_subscreen.dart';

class GlobalPoliciesScreen extends StatefulWidget {
  final Environment environment;

  const GlobalPoliciesScreen(this.environment, {super.key});

  @override
  State<GlobalPoliciesScreen> createState() => _GlobalPoliciesScreenState();
}

class _GlobalPoliciesScreenState extends State<GlobalPoliciesScreen> {
  int _currentIndex = 0;
  int _counter = 0;
  final List<Tab> _tabs = [];

  Tab generateTab(Key key) {
    late Tab tab;
    tab = Tab(
      text: Text('Tab $_counter'),
      key: key,
      semanticLabel: 'Tab #${_counter++}',
      icon: const FlutterLogo(),
      body: SingleChildScrollView(
        key: key,
        child: GlobalPoliciesSubScreen(
          widget.environment,
        ),
      ),
      onClosed: () {
        setState(() {
          Key viewedTabKey = _tabs[_currentIndex].key!;
          int closedTabIndex = _tabs.indexWhere((tab) => tab.key == key);
          // print("Viewing Tab at Index: $_currentIndex with Key: $viewedTabKey");
          // print("Closing Tab at Index: $closedTabIndex with key: $key");
          _tabs.removeWhere((tab) => tab.key == key);
          if (_currentIndex != closedTabIndex) {
            _currentIndex = _tabs.indexWhere((tab) => tab.key == viewedTabKey);
          } else {
            if (_currentIndex > 0) _currentIndex--;
          }

          // if (_tabs.isNotEmpty) {
          //   viewedTabKey = _tabs[_currentIndex].key!;
          //   print(
          //       "New Viewing Tab at Index: $_currentIndex with Key: $viewedTabKey");
          // }

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
      // onReorder: (oldIndex, newIndex) {
      //   setState(() {
      //     print(oldIndex);
      //     print(newIndex);
      //     print("");
      //     if (oldIndex < newIndex) {
      //       newIndex -= 1;
      //     }
      //     final item = _tabs.removeAt(oldIndex);
      //     _tabs.insert(newIndex, item);

      //     if (_currentIndex == newIndex) {
      //       _currentIndex = oldIndex;
      //     } else if (_currentIndex == oldIndex) {
      //       _currentIndex = newIndex;
      //     }
      //   });
      // },
    );
  }
}
