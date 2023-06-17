import 'package:fluent_ui/fluent_ui.dart';
import 'package:logger/logger.dart';
import 'package:system_theme/system_theme.dart';

enum Realm { admin, provider }

enum ChangeType { organization, catalog, configuredGateway, mediaType }

enum ContentType { yaml, json }

enum SortType { none, ascending, created, descending, recent }

enum RetrievalType { pages, all }

enum AppType { singlePageApp, mutliPageApp }

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

  static String getContentTypeString(ContentType type) {
    switch (type) {
      case ContentType.yaml:
        return "application/yaml";
      case ContentType.json:
        return "application/json";
    }
  }

  static String appDocumentDirectoryPath = "";

  static late Logger logger;

  static const String debugginProxyURL = "https://localhost:2000";
}
