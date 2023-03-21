import 'package:fluent_ui/fluent_ui.dart';

import './global_policies_screen.dart';
import './products_screen.dart';
import '../models/environment.dart';
import '../widgets/home_app_bar.dart';

class EnvironmentScreen extends StatefulWidget {
  final Environment environment;

  const EnvironmentScreen(this.environment, {super.key});
  static const String routeName = '/environment';

  @override
  State<EnvironmentScreen> createState() => _EnvironmentScreenState();
}

class _EnvironmentScreenState extends State<EnvironmentScreen> {
  int _currentIndex = 0;
  late final List<Tab> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      Tab(
        text: const Text('Products'),
        body: ProductsScreen(widget.environment),
      ),
      Tab(
        text: const Text('Global Policies'),
        body: GlobalPoliciesScreen(widget.environment),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: const HomeAppBar(),
      content: TabView(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
        tabWidthBehavior: TabWidthBehavior.equal,
        closeButtonVisibility: CloseButtonVisibilityMode.never,
        showScrollButtons: true,
        wheelScroll: false,
      ),
    );
  }
}
