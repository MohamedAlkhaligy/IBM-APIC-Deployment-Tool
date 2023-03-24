import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';

enum Realm { admin, provider }

enum ChangeType { organization, catalog, configuredGateway, mediaType }

enum SortType { ascending, created, descending, recent }

class GlobalConfigurations {
  static Map<String, Color> fluentUISwatch = <String, Color>{
    'darkest': SystemTheme.accentColor.darkest,
    'darker': SystemTheme.accentColor.darker,
    'dark': SystemTheme.accentColor.dark,
    'normal': SystemTheme.accentColor.accent,
    'light': SystemTheme.accentColor.light,
    'lighter': SystemTheme.accentColor.lighter,
    'lightest': SystemTheme.accentColor.lightest,
  };

  static const String debugginProxyURL = "https://localhost:2000";
}
