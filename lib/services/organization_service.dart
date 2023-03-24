import 'dart:convert';

import 'package:logger/logger.dart';

import './auth_service.dart';
import '../models/environment.dart';
import '../models/http_headers.dart';
import '../models/organizations/list_organizations_response_body.dart';
import '../models/organizations/organization.dart';
import '../utilities/http_utilities.dart';

class OrganizationsService {
  static final _organizationCore = OrganizationsService._internal();

  OrganizationsService._internal();

  factory OrganizationsService.getInstance() {
    return _organizationCore;
  }

  Future<List<Organization>> listOrgs(Environment environment,
      {String queryParameters = ""}) async {
    List<Organization> orgs = [];
    final logger = Logger();
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      String url = '${environment.serverURL}/api/orgs?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: environment.accessToken,
      );

      var httpResponse = await HTTPUtilites.getInstance()
          .get(url, headers.typedJson, ignoreUIError: true);

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
        final listOrganizationsResponseBody =
            ListOrganizationsResponseBody.fromJson(jsonResponseBody);
        orgs = listOrganizationsResponseBody.result;
        logger.i("OrganizationsService:listOrgs");
      }
    } catch (error, stackTrace) {
      logger.e("OrganizationsService:listOrgs", error, stackTrace);
    }
    return orgs;
  }
}
