import 'package:flutter/services.dart' show rootBundle;

import 'package:logger/logger.dart';

class FileUtilities {
  static Future<String> loadFileAsString(String path) async {
    try {
      return await rootBundle.loadString(path);
    } on Exception catch (error, stackTrace) {
      var logger = Logger();
      logger.e("FileUtilities:loadFileAsString", error, stackTrace);
      return "";
    }
  }
}
