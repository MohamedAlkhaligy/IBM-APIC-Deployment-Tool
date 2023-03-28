import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ibm_apic_dt/screens/environment_screen.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

import './global_configurations.dart';
import './models/environment.dart';
import './models/environments.dart';
import './navigation_service.dart';
import './providers/environments_provider.dart';
import './screens/home_screen.dart';
import './utilities/routing_utilities.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter("${Directory.current.path}\\hive\\");
  Hive.registerAdapter(EnvironmentsAdapter());
  Hive.registerAdapter(EnvironmentAdapter());
  final environmenstBox = await Hive.openBox<Environments>('environmentBox');
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (context) => EnvironmentsProvider(environmenstBox)),
    ],
    child: const App(),
  ));
  SystemTheme.accentColor.load();
  // Logger.level = Level.nothing;
}

// This is used if the platform is Windows and while in development mode
// Allows self-signed certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Logger.level = Level.nothing;
    if (Platform.isWindows) {
      HttpOverrides.global = MyHttpOverrides();
    }
    return FluentApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Deployment Tool',
      themeMode: ThemeMode.dark,
      darkTheme: FluentThemeData(
        scrollbarTheme: const ScrollbarThemeData()
            .merge(const ScrollbarThemeData(thickness: 8)),
        scaffoldBackgroundColor: const Color.fromRGBO(20, 20, 20, 1),
        brightness: Brightness.dark,
        accentColor: AccentColor.swatch(GlobalConfigurations.fluentUISwatch),
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0,
        ),
      ),
      initialRoute: HomeScreen.routeName,
      // home: EnvironmentScreen(
      //   Environment(
      //       serverURL: 'https://127.0.0.1:2000',
      //       environmentName: 'Local',
      //       clientID: "599b7aef-8841-4ee2-88a0-84d49c4d6ff2",
      //       clientSecret: "0ea28423-e73b-47d4-b40e-ddb45c48bb0c",
      //       username: 'shavon',
      //       password: '7iron-hide',
      //       accessToken: '',
      //       creationTime: DateTime.now(),
      //       environmentID: '1',
      //       lastVisited: DateTime.now()),
      // ),

      // routes: RoutingUtilities.routes,
      onGenerateRoute: RoutingUtilities.generateRoute,
    );
  }
}
