import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../global_configurations.dart';
import '../models/environments.dart';
import '../models/environment.dart';
import '../screens/environment_screen.dart';
import '../screens/home_navigator_screen.dart';

// ignore: constant_identifier_names
const ENVIRONMENTS = "environments";

@HiveType(typeId: 0)
class EnvironmentsProvider with ChangeNotifier {
  final Box<Environments> _environmentsBox;

  EnvironmentsProvider(this._environmentsBox);

  List<Environment> get environments {
    Environments? environments =
        _environmentsBox.get(ENVIRONMENTS) ?? Environments([]);
    return environments.environments;
  }

  Environment getEnvironmentById(String id) {
    return environments
        .firstWhere((environment) => environment.environmentID == id);
  }

  deleteEnvironment(Environment environment) {
    Environments environments =
        _environmentsBox.get(ENVIRONMENTS) ?? Environments([]);
    environments.environments.removeWhere(
        (element) => environment.environmentID == element.environmentID);
    _environmentsBox.put(ENVIRONMENTS, environments);
    _releaseEnvironmentScreenPage(environment);
    notifyListeners();
  }

  /// This is to release memory used by the environment screen
  void _releaseEnvironmentScreenPage(environment) {
    if (GlobalConfigurations.appType == AppType.singlePageApp) {
      int index = HomeNavigatorScreen.pages.indexWhere((pageWidget) =>
          (pageWidget is EnvironmentScreen &&
              pageWidget.environment.environmentID ==
                  environment.environmentID));
      if (index != -1) {
        HomeNavigatorScreen.pages[index] = const SizedBox();
      }
    }
  }

  addEnvironment(Environment environment) {
    Environments environments =
        _environmentsBox.get(ENVIRONMENTS) ?? Environments([]);
    environments.environments.add(environment);
    _environmentsBox.put(ENVIRONMENTS, environments);
    if (GlobalConfigurations.appType == AppType.singlePageApp) {
      HomeNavigatorScreen.pages.add(EnvironmentScreen(environment));
    }
    notifyListeners();
  }

  visitEnvironment(Environment environment) {
    environment.lastVisited = DateTime.now();
    notifyListeners();
  }
}
