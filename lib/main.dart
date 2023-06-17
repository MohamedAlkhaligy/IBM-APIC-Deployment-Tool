import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ibm_apic_dt/screens/environment_screen.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import './global_configurations.dart';
import './models/environment.dart';
import './models/environments.dart';
import './navigation_service.dart';
import './providers/environments_provider.dart';
import './screens/home_screen.dart';
import './utilities/routing_utilities.dart';
import 'screens/home_navigator_screen.dart';

void createAppDirectories(String appDocumentDirectoryPath) {
  String hivePath = "$appDocumentDirectoryPath\\hive";
  String tempPath = "$appDocumentDirectoryPath\\temp";
  String logsPath = "$appDocumentDirectoryPath\\logs";
  Directory(hivePath).create(recursive: true);
  Directory(tempPath).create(recursive: true);
  Directory(logsPath).create(recursive: true);
}

Future<void> loadConfigurations() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalConfigurations.appDocumentDirectoryPath =
      "${(await getApplicationDocumentsDirectory()).path}\\IBM API Connect Deployment Tool";
  createAppDirectories(GlobalConfigurations.appDocumentDirectoryPath);
  if (kReleaseMode) {
    File logFile = await File(
            "${GlobalConfigurations.appDocumentDirectoryPath}\\logs\\log.txt")
        .create(recursive: true);
    GlobalConfigurations.logger = Logger(
      output: FileOutput(file: logFile),
      printer: PrettyPrinter(
        printTime: true,
        colors: false,
      ),
      filter: ProductionFilter(),
      level: Level.error,
    );
  } else {
    GlobalConfigurations.logger =
        Logger(printer: PrettyPrinter(printTime: true));
  }
}

Future<EnvironmentsProvider> loadEnvironmentsProviderFromHiveDatabase() async {
  await Hive.initFlutter(
      "${GlobalConfigurations.appDocumentDirectoryPath}\\hive");

  Hive.registerAdapter(EnvironmentsAdapter());
  Hive.registerAdapter(EnvironmentAdapter());

  const secureStorage = FlutterSecureStorage();
  final encryptionKeyString = await secureStorage.read(key: 'environmentsKey');
  if (encryptionKeyString == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'environmentsKey',
      value: base64UrlEncode(key),
    );
  }

  final key = await const FlutterSecureStorage().read(key: 'environmentsKey');
  final encryptionKeyUint8List = base64Url.decode(key!);
  final environmenstBox = await Hive.openBox<Environments>(
    'environmentBox',
    encryptionCipher: HiveAesCipher(encryptionKeyUint8List),
  );
  return EnvironmentsProvider(environmenstBox);
}

void main() async {
  await loadConfigurations();
  final environmentsProvider = await loadEnvironmentsProviderFromHiveDatabase();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => environmentsProvider),
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
    if (Platform.isWindows) {
      HttpOverrides.global = MyHttpOverrides();
    }
    String title = 'Deployment Tool';
    FluentThemeData theme = FluentThemeData(
      scrollbarTheme: const ScrollbarThemeData()
          .merge(const ScrollbarThemeData(thickness: 8)),
      scaffoldBackgroundColor: const Color.fromRGBO(20, 20, 20, 1),
      brightness: Brightness.dark,
      accentColor: AccentColor.swatch(GlobalConfigurations.fluentUISwatch),
      visualDensity: VisualDensity.standard,
      focusTheme: FocusThemeData(
        glowFactor: is10footScreen() ? 2.0 : 0.0,
      ),
    );
    if (GlobalConfigurations.appType == AppType.singlePageApp) {
      return FluentApp(
        navigatorKey: NavigationService.navigatorKey,
        title: title,
        themeMode: ThemeMode.dark,
        darkTheme: theme,
        home: const HomeNavigatorScreen(),
        onGenerateRoute: RoutingUtilities.generateRoute,
      );
    }
    return FluentApp(
      navigatorKey: NavigationService.navigatorKey,
      title: title,
      themeMode: ThemeMode.dark,
      darkTheme: theme,
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
