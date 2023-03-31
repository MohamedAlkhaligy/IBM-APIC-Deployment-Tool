import '../global_configurations.dart';
import '../models/catalogs/catalog.dart';
import '../models/environment.dart';
import '../models/gateways/configured_gateway.dart';
import '../models/global_policies/global_policy_meta.dart';
import '../models/organizations/organization.dart';
import '../services/catalogs_service.dart';
import '../services/configured_gateway_service.dart';
import '../services/global_policies_service.dart';
import '../services/organization_service.dart';

enum FileMediaType { yaml, json }

enum GlobalPolicyType { none, input, output, inputOutput, error }

class GlobalPolicyInfo {
  GlobalPolicyType globalPolicyType;
  final GlobalPolicyMeta globalPolicyMeta;

  GlobalPolicyInfo(this.globalPolicyType, this.globalPolicyMeta);
}

class GlobalPoliciesController {
  final Environment _environment;

  int _organizationIndex, _catalogIndex, _configuredGatewayIndex;
  FileMediaType mediaType;
  List<Organization> orgs;
  List<Catalog> catalogs;
  List<ConfiguredGateway> configuredGateways;
  List<GlobalPolicyInfo> globalPolicies;

  GlobalPoliciesController(this._environment)
      : _organizationIndex = 0,
        _catalogIndex = 0,
        _configuredGatewayIndex = 0,
        orgs = [],
        catalogs = [],
        configuredGateways = [],
        globalPolicies = [],
        mediaType = FileMediaType.yaml;

  int get organizationIndex => _organizationIndex;

  set organizationIndex(int value) => _organizationIndex = value;

  set catalogIndex(int value) => _catalogIndex = value;

  int get catalogIndex => _catalogIndex;

  set configuredGatewayIndex(int value) => _configuredGatewayIndex = value;

  int get configuredGatewayIndex => _configuredGatewayIndex;

  Future<String> getGlobalPolicy(int globalPolicyIndex) async {
    return await await GlobalPoliciesService.getInstance().getGlobalPolicyYAML(
        environment: _environment,
        organizationName: orgs[_organizationIndex].name!,
        catalogName: catalogs[_catalogIndex].name,
        configuredGatewayName: configuredGateways[_configuredGatewayIndex].name,
        globalPolicyName:
            globalPolicies[globalPolicyIndex].globalPolicyMeta.name,
        globalPolicyVersion:
            globalPolicies[globalPolicyIndex].globalPolicyMeta.version!);
  }

  Future<bool> deleteGlobalPolicy(int globalPolicyIndex) async {
    return await GlobalPoliciesService.getInstance().deleteGlobalPolicy(
      environment: _environment,
      organizationName: orgs[_organizationIndex].name!,
      catalogName: catalogs[_catalogIndex].name,
      configuredGatewayName: configuredGateways[_configuredGatewayIndex].name,
      globalPolicyName: globalPolicies[globalPolicyIndex].globalPolicyMeta.name,
      globalPolicyVersion:
          globalPolicies[globalPolicyIndex].globalPolicyMeta.version!,
    );
  }

  void _clearData() {
    orgs = [];
    catalogs = [];
    configuredGateways = [];
    globalPolicies = [];
  }

  Future<void> applyChange(ChangeType changeType) async {
    switch (changeType) {
      case ChangeType.organization:
        await _applyOrganizationChanges();
        break;
      case ChangeType.catalog:
        await _applyCatalogChanges();
        break;
      case ChangeType.configuredGateway:
        break;
      case ChangeType.mediaType:
        break;
    }
    globalPolicies = [];
    if (catalogs.isNotEmpty &&
        orgs.isNotEmpty &&
        configuredGateways.isNotEmpty) {
      await _loadGlobalPolicies(
          orgs[_organizationIndex].name!,
          catalogs[_catalogIndex].name,
          configuredGateways[_configuredGatewayIndex].name);
    }
  }

  Future<void> handleGlobalPolicyAssignment(
      int globalPolicyIndex, GlobalPolicyType type) async {
    final globalPoliciesService = GlobalPoliciesService.getInstance();
    Function assignGlobalPolicy =
        globalPoliciesService.assignPrehookGlobalPolicy;
    switch (type) {
      case GlobalPolicyType.input:
        assignGlobalPolicy = globalPoliciesService.assignPrehookGlobalPolicy;
        break;
      case GlobalPolicyType.output:
        assignGlobalPolicy = globalPoliciesService.assignPosthookGlobalPolicy;
        break;
      case GlobalPolicyType.error:
        assignGlobalPolicy = globalPoliciesService.assignErrorGlobalPolicy;
        break;
      default:
    }
    bool isAssigned = await assignGlobalPolicy(
        environment: _environment,
        organizationName: orgs[_organizationIndex].name!,
        catalogName: catalogs[_catalogIndex].name,
        configuredGatewayName: configuredGateways[_configuredGatewayIndex].name,
        globalPolicyUrl:
            globalPolicies[globalPolicyIndex].globalPolicyMeta.url!);
    if (isAssigned) {
      globalPolicies[globalPolicyIndex].globalPolicyType = type;
    }
  }

  Future<void> handleGlobalPolicyUnassignment(
      int globalPolicyIndex, GlobalPolicyType type) async {
    final globalPoliciesService = GlobalPoliciesService.getInstance();
    Function deleteGlobalPolicy =
        globalPoliciesService.deletePrehookGlobalPolicy;
    switch (type) {
      case GlobalPolicyType.input:
        deleteGlobalPolicy = globalPoliciesService.deletePrehookGlobalPolicy;
        break;
      case GlobalPolicyType.output:
        deleteGlobalPolicy = globalPoliciesService.deletePosthookGlobalPolicy;
        break;
      case GlobalPolicyType.error:
        deleteGlobalPolicy = globalPoliciesService.deleteErrorGlobalPolicy;
        break;
      default:
    }
    bool isAssigned = await deleteGlobalPolicy(
      environment: _environment,
      organizationName: orgs[_organizationIndex].name!,
      catalogName: catalogs[_catalogIndex].name,
      configuredGatewayName: configuredGateways[_configuredGatewayIndex].name,
    );
    if (isAssigned) {
      globalPolicies[globalPolicyIndex].globalPolicyType =
          GlobalPolicyType.none;
    }
  }

  Future<void> _applyOrganizationChanges() async {
    _catalogIndex = 0;
    _configuredGatewayIndex = 0;
    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty) return;

    configuredGateways = await ConfiguredGatewayService.getInstance()
        .listConfiguredGateways(
            _environment, orgs[_organizationIndex].name!, catalogs[0].name,
            queryParameters: "fields=name&fields=title");
  }

  Future<void> _applyCatalogChanges() async {
    _configuredGatewayIndex = 0;
    configuredGateways = await ConfiguredGatewayService.getInstance()
        .listConfiguredGateways(_environment, orgs[_organizationIndex].name!,
            catalogs[_catalogIndex].name,
            queryParameters: "fields=name&fields=title");
  }

  Future<void> loadData() async {
    orgs = await OrganizationsService.getInstance().listOrgs(_environment,
        queryParameters: "fields=name&fields=title&fields=owner_url");
    if (orgs.isEmpty) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[0].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty) return;

    configuredGateways = await ConfiguredGatewayService.getInstance()
        .listConfiguredGateways(_environment, orgs[0].name!, catalogs[0].name,
            queryParameters: "fields=name&fields=title");
    if (configuredGateways.isEmpty) return;

    await _loadGlobalPolicies(
        orgs[0].name!, catalogs[0].name, configuredGateways[0].name);
  }

  Future<void> _loadGlobalPolicies(String organizationName, String catalogName,
      String configuredGatewayName) async {
    final globalPoliciesService = GlobalPoliciesService.getInstance();
    final prehookGlobalPolicy =
        await globalPoliciesService.getPrehookGlobalPolicy(
      _environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: "fields=name&fields=global_policy_url",
      ignoreUIError: true,
    );
    final posthookGlobalPolicy =
        await globalPoliciesService.getPosthookGlobalPolicy(
      _environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: "fields=name&fields=global_policy_url",
      ignoreUIError: true,
    );
    final errorGlobalPolicy = await globalPoliciesService.getErrorGlobalPolicy(
      _environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: "fields=name&fields=global_policy_url",
      ignoreUIError: true,
    );

    final prehookGlobalPolicyURL = prehookGlobalPolicy?.globalPolicyURL;
    final posthookGlobalPolicyURL = posthookGlobalPolicy?.globalPolicyURL;
    final errorGlobalPolicyURL = errorGlobalPolicy?.globalPolicyURL;

    globalPolicies = (await globalPoliciesService.listGlobalPolicies(
      _environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: "fields=name&fields=title&fields=url&fields=version",
    ))
        .map((globalPolicy) {
      GlobalPolicyType type = GlobalPolicyType.none;
      if (globalPolicy.url == prehookGlobalPolicyURL) {
        type = GlobalPolicyType.input;
      } else if (globalPolicy.url == posthookGlobalPolicyURL) {
        type = GlobalPolicyType.output;
      } else if (globalPolicy.url == errorGlobalPolicyURL) {
        type = GlobalPolicyType.error;
      }
      return GlobalPolicyInfo(type, globalPolicy);
    }).toList();
  }

  bool areDataAvailable() {
    return orgs.isNotEmpty &&
        catalogs.isNotEmpty &&
        configuredGateways.isNotEmpty;
  }

  Future<void> refreshData() async {
    _clearData();
    orgs = await OrganizationsService.getInstance().listOrgs(_environment,
        queryParameters: "fields=name&fields=title&fields=owner_url");
    if (orgs.isEmpty || _organizationIndex >= orgs.length) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        _environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty || _catalogIndex >= catalogs.length) return;

    configuredGateways = await ConfiguredGatewayService.getInstance()
        .listConfiguredGateways(_environment, orgs[_organizationIndex].name!,
            catalogs[_catalogIndex].name,
            queryParameters: "fields=name&fields=title");
    if (configuredGateways.isEmpty ||
        _configuredGatewayIndex >= configuredGateways.length) return;

    await _loadGlobalPolicies(
      orgs[_organizationIndex].name!,
      catalogs[_catalogIndex].name,
      configuredGateways[_configuredGatewayIndex].name,
    );
  }
}
