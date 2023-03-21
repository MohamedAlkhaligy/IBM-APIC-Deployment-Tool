import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/models/environment.dart';
import 'package:ibm_apic_dt/screens/environment_screen.dart';

import '../screens/add_environment_screen.dart';
import '../screens/home_screen.dart';

class RoutingUtilities {
  static Map<String, Widget Function(BuildContext)> routes =
      <String, Widget Function(BuildContext)>{
    HomeScreen.routeName: (context) => const HomeScreen(),
    AddEnvironmentScreen.routeName: (context) => const AddEnvironmentScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case '/':
      case HomeScreen.routeName:
        return FluentPageRoute(builder: (_) => const HomeScreen());
      case AddEnvironmentScreen.routeName:
        return FluentPageRoute(builder: (_) => const AddEnvironmentScreen());
      case EnvironmentScreen.routeName:
        Environment environment = settings.arguments as Environment;
        return FluentPageRoute(builder: (_) => EnvironmentScreen(environment));
      default:
        return FluentPageRoute(
          builder: (_) => ScaffoldPage(
            content: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
