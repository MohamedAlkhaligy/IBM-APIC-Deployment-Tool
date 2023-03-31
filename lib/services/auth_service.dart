import 'dart:convert';

import 'package:logger/logger.dart';

import '../global_configurations.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response_body.dart';
import '../models/environment.dart';
import '../models/http_headers.dart';
import '../utilities/error_handling_utilities.dart';
import '../utilities/file_utilities.dart';
import '../utilities/http_utilities.dart';

class AuthService {
  static final _authService = AuthService._internal();

  AuthService._internal();

  factory AuthService.getInstance() {
    return _authService;
  }

  // Future<void> introspectAndLogin(Environment environment) async {
  //   bool isValidToken = await AuthService.getInstance()
  //       .introspect(environment, queryParameters: "fields=name");
  //   if (!isValidToken) {
  //     environment.accessToken = await AuthService.getInstance().login(
  //       clientID: environment.clientID,
  //       clientSecret: environment.clientSecret,
  //       serverURL: environment.serverURL,
  //       username: environment.username,
  //       password: environment.password,
  //     );
  //   }
  // }

  Future<String> login({
    required String clientID,
    required String clientSecret,
    required String serverURL,
    required String username,
    required String password,
    Realm realm = Realm.provider,
  }) async {
    final logger = GlobalConfigurations.logger;

    try {
      final loginJsonTemplate = await FileUtilities.loadFileAsString(
          "assets/json/templates/login.json");

      final jsonRequest = json.decode(loginJsonTemplate);
      final request = LoginRequest.fromJson(jsonRequest);

      request.body.password = password;
      request.body.username = username;
      request.body.clientID = clientID;
      request.body.clientSecret = clientSecret;
      request.body.realm = (realm == Realm.admin)
          ? "admin/default-idp-1"
          : "provider/default-idp-2";

      String url = '$serverURL/api/token';

      final httpResponse = await HTTPUtilites.getInstance().post(
        url,
        json.encode(request.body.toJson()),
        request.headers.typedJson,
      );
      if (httpResponse != null) {
        final jsonResponseBody = json.decode(httpResponse.body);
        final response = LoginResponseBody.fromJson(jsonResponseBody);
        return response.accessToken;
      }
    } catch (error) {
      logger.e("AuthService:login", error);
      // ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return "";
  }

  Future<bool> introspect(Environment environment,
      {String queryParameters = ""}) async {
    try {
      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: environment.accessToken,
      );

      final url = '${environment.serverURL}/api/me?$queryParameters';
      final httpResponse = await HTTPUtilites.getInstance()
          .get(url, headers.typedJson, ignoreUIError: true);
      if (httpResponse != null) {
        return true;
      }
    } catch (error) {
      var logger = Logger(level: Level.error);
      logger.e("AuthService:introspect", error);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return false;
  }
}
