import 'package:flutter/material.dart';

import '../navigation_service.dart';
import '../widgets/error_pop_up.dart';

class ErrorHandlingUtilities {
  static final _errorHandlingUtilities = ErrorHandlingUtilities._internal();

  ErrorHandlingUtilities._internal();

  static ErrorHandlingUtilities get instance {
    return _errorHandlingUtilities;
  }

  Future<bool?> showPopUpError(String message,
      {List<String>? errors, BuildContext? ctx}) {
    BuildContext? context =
        (ctx != null) ? ctx : NavigationService.navigatorKey.currentContext;
    if (context != null) {
      return showDialog<bool>(
        context: context,
        builder: (ctx) => ErrorPopUp(
          message,
          errors: errors,
        ),
      );
    }
    return Future.value(true);
  }
}
