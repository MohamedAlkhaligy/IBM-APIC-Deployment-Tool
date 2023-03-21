import 'dart:convert';

import 'package:logger/logger.dart';

import './auth_service.dart';
import '../global_configurations.dart';
import '../models/gateways/configured_gateway.dart';
import '../models/environment.dart';
import '../models/http_headers.dart';
import '../models/gateways/list_configured_gateways_response_body.dart';
import '../utilities/http_utilities.dart';

class ConfiguredGatewayService {
  static final _configuredGatewayService = ConfiguredGatewayService._internal();

  ConfiguredGatewayService._internal();

  factory ConfiguredGatewayService.getInstance() {
    return _configuredGatewayService;
  }

  Future<List<ConfiguredGateway>> listConfiguredGateways(
      Environment environment, String organizationName, String catalogName,
      {String queryParameters = ""}) async {
    List<ConfiguredGateway> orgs = [];
    final logger = Logger();
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      final accessToken = environment.accessToken;
      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: accessToken,
        xProxyTargetURL: environment.serverURL,
      );

      var httpResponse =
          await HTTPUtilites.getInstance().get(url, headers.typedJson);

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
        httpResponse =
            await HTTPUtilites.getInstance().get(url, headers.typedJson);
      }

      if (httpResponse != null && httpResponse.statusCode == 200) {
        final jsonResponseBody = json.decode(httpResponse.body);
        final listConfiguredGatewaysResponseBody =
            ListConfiguredGatewaysResponseBody.fromJson(jsonResponseBody);
        orgs = listConfiguredGatewaysResponseBody.result;
        logger.i("ConfiguredGatewayService:listConfiguredGateways");
      }
    } catch (error, stackTrace) {
      logger.e(
          "ConfiguredGatewayService:listConfiguredGateways", error, stackTrace);
    }
    return orgs;
  }
}
