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

class _EnvironmentScreenState extends State<EnvironmentScreen>
    with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  late final List<Tab> _tabs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabs = [
      Tab(
        key: UniqueKey(),
        text: const Text('Products'),
        body: ProductsScreen(widget.environment),
      ),
      Tab(
        key: UniqueKey(),
        text: const Text('Global Policies'),
        body: GlobalPoliciesScreen(widget.environment),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      header: HomeAppBar(
        text: "${widget.environment.environmentName} Environment",
      ),
      content: TabView(
        tabs: _tabs,
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
        tabWidthBehavior: TabWidthBehavior.equal,
        closeButtonVisibility: CloseButtonVisibilityMode.never,
        showScrollButtons: true,
      ),
    );
  }
}
