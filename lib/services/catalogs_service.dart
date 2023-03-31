import 'dart:convert';

import 'package:logger/logger.dart';

import '../global_configurations.dart';
import '../models/catalogs/catalog.dart';
import '../models/catalogs/list_catalogs_response_body.dart';
import '../models/environment.dart';
import '../models/http_headers.dart';
import '../utilities/error_handling_utilities.dart';
import '../utilities/http_utilities.dart';
import 'auth_service.dart';

class CatalogsService {
  static final _catalogsService = CatalogsService._internal();

  CatalogsService._internal();

  factory CatalogsService.getInstance() {
    return _catalogsService;
  }

  Future<List<Catalog>> listCatalogs(
    Environment environment,
    String organizationName, {
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    List<Catalog> catalogs = [];
    final logger = GlobalConfigurations.logger;
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      final accessToken = environment.accessToken;
      String url =
          '${environment.serverURL}/api/orgs/$organizationName/catalogs?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: accessToken,
      );

      var httpResponse = await HTTPUtilites.getInstance().get(
        url,
        headers.typedJson,
        ignoreUIError: ignoreUIError,
        ignoreReauthError: true,
      );

      if (httpResponse != null && httpResponse.statusCode == 401) {
        final accessToken = await AuthService.getInstance().login(
          clientID: environment.clientID,
          clientSecret: environment.clientSecret,
          serverURL: environment.serverURL,
          username: environment.username,
          password: environment.password,
        );
        environment.accessToken = accessToken;
        headers.authorization = accessToken;
        httpResponse = await HTTPUtilites.getInstance().get(
          url,
          headers.typedJson,
          ignoreUIError: ignoreUIError,
        );
      }

      if (httpResponse != null && httpResponse.statusCode == 200) {
        final jsonResponseBody = json.decode(httpResponse.body);
        final listCatalogsResponseBody =
            ListCatalogsResponseBody.fromJson(jsonResponseBody);
        catalogs = listCatalogsResponseBody.result;
        logger.i("CatalogsService:listCatalogs");
      }
    } catch (error, stackTrace) {
      logger.e("CatalogsService:listCatalogs", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }

    return catalogs;
  }
}
