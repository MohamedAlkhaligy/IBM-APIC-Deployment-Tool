import 'dart:convert';

import 'package:yaml/yaml.dart';

import '../dtos/global_policies/list_global_policies/response/list_global_policies_response_dto.dart';
import '../global_configurations.dart';
import './auth_service.dart';
import '../models/environment.dart';
import '../models/global_policies/global_policy_meta.dart';
import '../models/http_headers.dart';
import '../utilities/error_handling_utilities.dart';
import '../utilities/http_utilities.dart';

enum HookType { pre, post, error }

class GlobalPoliciesService {
  static final _globalPoliciesService = GlobalPoliciesService._internal();

  GlobalPoliciesService._internal();

  factory GlobalPoliciesService.getInstance() {
    return _globalPoliciesService;
  }

  final logger = GlobalConfigurations.logger;

  String mapHookType(HookType hookType) {
    switch (hookType) {
      case HookType.pre:
        return "prehook";
      case HookType.post:
        return "posthook";
      case HookType.error:
        return "error";
    }
  }

  Future<List<GlobalPolicyMeta>> listGlobalPolicies(
    Environment environment,
    String organizationName,
    String catalogName,
    String configuredGatewayName, {
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    List<GlobalPolicyMeta> globalPolicies = [];
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services/$configuredGatewayName/global-policies?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: environment.accessToken,
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
            ListGlobalPoliciesResponseDto.fromJson(jsonResponseBody);
        globalPolicies = listCatalogsResponseBody.result;
        logger.i("GlobalPoliciesService:listGlobalPolicies");
      }
    } catch (error, stackTrace) {
      logger.e("GlobalPoliciesService:listGlobalPolicies", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return globalPolicies;
  }

  Future<bool> uploadGlobalPolicy(
    String globalPolicyString, {
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    ignoreUIError = false,
    isJson = false,
  }) async {
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);
      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services/$configuredGatewayName/global-policies';

      final requestBody = {
        "global_policy": isJson
            ? json.decode(globalPolicyString)
            : loadYaml(globalPolicyString),
      };

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        contentType: 'application/json',
        authorization: environment.accessToken,
      );

      var httpResponse = await HTTPUtilites.getInstance().post(
        url,
        jsonEncode(requestBody),
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
        httpResponse = await HTTPUtilites.getInstance().post(
          url,
          jsonEncode(requestBody),
          headers.typedJson,
          ignoreUIError: ignoreUIError,
        );
      }

      if (httpResponse != null) {
        if (httpResponse.statusCode == 201) {
          return true;
        } else {
          ErrorHandlingUtilities.instance.showPopUpError(httpResponse.body);
        }
      }
    } catch (error) {
      logger.e("GlobalPoliciesService:uploadGlobalPolicy", error);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return false;
  }

  Future<bool> updateGlobalPolicy(
    String globalPolicyString, {
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    required String globalPolicyName,
    required String globalPolicyVersion,
    ignoreUIError = false,
    isJons = false,
  }) async {
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);
      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services/$configuredGatewayName/global-policies/$globalPolicyName/$globalPolicyVersion';

      final requestBody = {
        "global_policy": isJons
            ? json.decode(globalPolicyString)
            : loadYaml(globalPolicyString),
      };

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        contentType: 'application/json',
        authorization: environment.accessToken,
      );

      var httpResponse = await HTTPUtilites.getInstance().patch(
        url,
        jsonEncode(requestBody),
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
        httpResponse = await HTTPUtilites.getInstance().patch(
          url,
          jsonEncode(requestBody),
          headers.typedJson,
          ignoreUIError: ignoreUIError,
        );
      }

      if (httpResponse != null) {
        if (httpResponse.statusCode == 200) {
          return true;
        } else {
          ErrorHandlingUtilities.instance.showPopUpError(httpResponse.body);
        }
      }
    } catch (error) {
      logger.e("GlobalPoliciesService:updateGlobalPolicy", error);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return false;
  }

  Future<String> getGlobalPolicyYAML({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    required String globalPolicyName,
    required String globalPolicyVersion,
    ContentType contentType = ContentType.yaml,
    ignoreUIError = false,
  }) async {
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services/$configuredGatewayName/global-policies/$globalPolicyName/$globalPolicyVersion?fields=add(global_policy)&fields=global_policy';

      HTTPHeaders headers = HTTPHeaders(
        accept: GlobalConfigurations.getContentTypeString(contentType),
        authorization: environment.accessToken,
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
        return httpResponse.body;
      }
    } catch (error, stackTrace) {
      logger.e("GlobalPoliciesService:getGlobalPolicyYAML", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return '';
  }

  Future<bool> assignPrehookGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    required String globalPolicyUrl,
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return await _assignHookGlobalPolicy(
      environment: environment,
      organizationName: organizationName,
      catalogName: catalogName,
      configuredGatewayName: configuredGatewayName,
      globalPolicyUrl: globalPolicyUrl,
      queryParameters: queryParameters,
      hookType: HookType.pre,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<bool> assignPosthookGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    required String globalPolicyUrl,
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return await _assignHookGlobalPolicy(
      environment: environment,
      organizationName: organizationName,
      catalogName: catalogName,
      configuredGatewayName: configuredGatewayName,
      globalPolicyUrl: globalPolicyUrl,
      queryParameters: queryParameters,
      hookType: HookType.post,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<bool> assignErrorGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    required String globalPolicyUrl,
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return await _assignHookGlobalPolicy(
      environment: environment,
      organizationName: organizationName,
      catalogName: catalogName,
      configuredGatewayName: configuredGatewayName,
      globalPolicyUrl: globalPolicyUrl,
      queryParameters: queryParameters,
      hookType: HookType.error,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<bool> _assignHookGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    required String globalPolicyUrl,
    String queryParameters = "",
    HookType hookType = HookType.pre,
    bool ignoreUIError = false,
  }) async {
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      final requestBody = {
        'global_policy_url': globalPolicyUrl,
      };

      String hookTypeString = mapHookType(hookType);
      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services/$configuredGatewayName/global-policy-$hookTypeString?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        contentType: 'application/json',
        authorization: environment.accessToken,
      );

      var httpResponse = await HTTPUtilites.getInstance().post(
        url,
        json.encode(requestBody),
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
        httpResponse = await HTTPUtilites.getInstance().post(
          url,
          json.encode(requestBody),
          headers.typedJson,
          ignoreUIError: ignoreUIError,
        );
      }

      if (httpResponse != null && httpResponse.statusCode == 200) {
        return true;
      }
    } catch (error) {
      logger.e("GlobalPoliciesService:assignHookGlobalPolicy", error);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return false;
  }

  Future<GlobalPolicyMeta?> getPrehookGlobalPolicy(
    Environment environment,
    String organizationName,
    String catalogName,
    String configuredGatewayName, {
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return await _getHookGlobalPolicy(
      environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: queryParameters,
      hookType: HookType.pre,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<GlobalPolicyMeta?> getPosthookGlobalPolicy(
    Environment environment,
    String organizationName,
    String catalogName,
    String configuredGatewayName, {
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return await _getHookGlobalPolicy(
      environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: queryParameters,
      hookType: HookType.post,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<GlobalPolicyMeta?> getErrorGlobalPolicy(
    Environment environment,
    String organizationName,
    String catalogName,
    String configuredGatewayName, {
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return await _getHookGlobalPolicy(
      environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: queryParameters,
      hookType: HookType.error,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<GlobalPolicyMeta?> _getHookGlobalPolicy(
    Environment environment,
    String organizationName,
    String catalogName,
    String configuredGatewayName, {
    String queryParameters = "",
    HookType hookType = HookType.pre,
    bool ignoreUIError = false,
  }) async {
    GlobalPolicyMeta? globalPolicyMeta;
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      String hookTypeString = mapHookType(hookType);
      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services/$configuredGatewayName/global-policy-$hookTypeString?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: environment.accessToken,
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
        globalPolicyMeta = GlobalPolicyMeta.fromJson(jsonResponseBody);
        logger.i("GlobalPoliciesService:_getHookGlobalPolicy");
      }
    } catch (error, stackTrace) {
      logger.e("GlobalPoliciesService:_getHookGlobalPolicy", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return globalPolicyMeta;
  }

  Future<bool> deleteGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    required String globalPolicyName,
    required String globalPolicyVersion,
    String queryParameters = "",
    ignoreUIError = false,
  }) async {
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services/$configuredGatewayName/global-policies/$globalPolicyName/$globalPolicyVersion?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: environment.accessToken,
      );

      var httpResponse = await HTTPUtilites.getInstance().delete(
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
        httpResponse = await HTTPUtilites.getInstance().delete(
          url,
          headers.typedJson,
          ignoreUIError: ignoreUIError,
        );
      }

      if (httpResponse != null && httpResponse.statusCode == 200) {
        return true;
      }
    } catch (error, stackTrace) {
      logger.e("GlobalPoliciesService:listGlobalPolicies", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return false;
  }

  Future<bool> deletePrehookGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return _deleteHookGlobalPolicy(
      environment: environment,
      organizationName: organizationName,
      catalogName: catalogName,
      configuredGatewayName: configuredGatewayName,
      hookType: HookType.pre,
      queryParameters: queryParameters,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<bool> deletePosthookGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return _deleteHookGlobalPolicy(
      environment: environment,
      organizationName: organizationName,
      catalogName: catalogName,
      configuredGatewayName: configuredGatewayName,
      hookType: HookType.post,
      queryParameters: queryParameters,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<bool> deleteErrorGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    String queryParameters = "",
    bool ignoreUIError = false,
  }) async {
    return _deleteHookGlobalPolicy(
      environment: environment,
      organizationName: organizationName,
      catalogName: catalogName,
      configuredGatewayName: configuredGatewayName,
      hookType: HookType.error,
      queryParameters: queryParameters,
      ignoreUIError: ignoreUIError,
    );
  }

  Future<bool> _deleteHookGlobalPolicy({
    required Environment environment,
    required String organizationName,
    required String catalogName,
    required String configuredGatewayName,
    String queryParameters = "",
    HookType hookType = HookType.pre,
    bool ignoreUIError = false,
  }) async {
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      String hookTypeString = mapHookType(hookType);
      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/configured-gateway-services/$configuredGatewayName/global-policy-$hookTypeString?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: environment.accessToken,
      );

      var httpResponse = await HTTPUtilites.getInstance().delete(
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
        httpResponse = await HTTPUtilites.getInstance().delete(
          url,
          headers.typedJson,
          ignoreUIError: ignoreUIError,
        );
      }

      if (httpResponse != null && httpResponse.statusCode == 200) {
        return true;
      }
    } catch (error, stackTrace) {
      logger.e("GlobalPoliciesService:listGlobalPolicies", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }
    return false;
  }
}
