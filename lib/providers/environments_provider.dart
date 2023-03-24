import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/environments.dart';
import '../models/environment.dart';

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
    notifyListeners();
  }

  addEnvironment(Environment environment) {
    Environments environments =
        _environmentsBox.get(ENVIRONMENTS) ?? Environments([]);
    environments.environments.add(environment);
    _environmentsBox.put(ENVIRONMENTS, environments);
    notifyListeners();
  }

  visitEnvironment(Environment environment) {
    environment.lastVisited = DateTime.now();
    notifyListeners();
  }
}
