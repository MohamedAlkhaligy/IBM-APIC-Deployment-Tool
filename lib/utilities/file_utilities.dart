import 'package:flutter/services.dart' show rootBundle;

import 'package:logger/logger.dart';

import '../global_configurations.dart';

class FileUtilities {
  static Future<String> loadFileAsString(String path) async {
    try {
      return await rootBundle.loadString(path);
    } on Exception catch (error, stackTrace) {
      final logger = GlobalConfigurations.logger;
      logger.e("FileUtilities:loadFileAsString", error, stackTrace);
      return "";
    }
  }
}
