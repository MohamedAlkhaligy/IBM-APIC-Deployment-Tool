import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/providers/environments_provider.dart';
import 'package:ibm_apic_dt/screens/add_environment_screen.dart';
import 'package:ibm_apic_dt/screens/environment_screen.dart';
import 'package:provider/provider.dart';

import 'environments_navigator_screen.dart';

class HomeNavigatorScreen extends StatefulWidget {
  const HomeNavigatorScreen({super.key});

  static const int viewEnvironmentsPageIndex = 0;
  static const int addEnvironmentPageIndex = 1;
  static final PageController pageController = PageController(initialPage: 0);
  static final List<Widget> pages = [
    const EnvironmentsNavigatorScreen(),
    const AddEnvironmentScreen(),
  ];

  @override
  State<HomeNavigatorScreen> createState() => _HomeNavigatorScreenState();
}

class _HomeNavigatorScreenState extends State<HomeNavigatorScreen> {
  @override
  void initState() {
    super.initState();
    HomeNavigatorScreen.pages
        .addAll(Provider.of<EnvironmentsProvider>(context, listen: false)
            .environments
            .map((environment) => EnvironmentScreen(
                  environment,
                  key: GlobalKey(),
                ))
            .toList());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: HomeNavigatorScreen.pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: HomeNavigatorScreen.pages,
    );
  }
}
