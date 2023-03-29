// import 'dart:convert';
// import 'dart:html';

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/widgets/choices_pop_up.dart';
import 'package:path/path.dart';

import '../global_configurations.dart';
import '../navigation_service.dart';
import '../widgets/confirmation_pop_up.dart';
import './upload_global_policy_screen.dart';
import '../models/catalogs/catalog.dart';
import '../models/environment.dart';
import '../models/gateways/configured_gateway.dart';
import '../models/global_policies/global_policy_meta.dart';
import '../models/organizations/organization.dart';
import '../services/catalogs_service.dart';
import '../services/configured_gateway_service.dart';
import '../services/global_policies_service.dart';
import '../services/organization_service.dart';
import '../widgets/loader.dart';
import '../widgets/responsive_text.dart';
import '../widgets/yaml_viewer.dart';

class GlobalPoliciesSubScreen extends StatefulWidget {
  final Environment environment;

  const GlobalPoliciesSubScreen(this.environment, {super.key});

  @override
  State<GlobalPoliciesSubScreen> createState() =>
      _GlobalPoliciesSubScreenState();
}

enum FileMediaType { yaml, json }

enum GlobalPolicyType { none, input, output, inputOutput, error }

class _CustomGlobalPolicyMeta {
  GlobalPolicyType globalPolicyType;
  final GlobalPolicyMeta globalPolicyMeta;

  _CustomGlobalPolicyMeta(this.globalPolicyType, this.globalPolicyMeta);
}

class _GlobalPoliciesSubScreenState extends State<GlobalPoliciesSubScreen> {
  int _organizationIndex = 0, _catalogIndex = 0, _configuredGatewayIndex = 0;
  bool _isLoading = false;
  FileMediaType mediaType = FileMediaType.yaml;
  List<Organization> orgs = [];
  List<Catalog> catalogs = [];
  List<ConfiguredGateway> configuredGateways = [];
  List<_CustomGlobalPolicyMeta> globalPolicies = [];

  void _clearData() {
    orgs = [];
    catalogs = [];
    configuredGateways = [];
    globalPolicies = [];
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    _clearData();
    orgs = await OrganizationsService.getInstance().listOrgs(widget.environment,
        queryParameters: "fields=name&fields=title&fields=owner_url");
    if (orgs.isEmpty || _organizationIndex >= orgs.length) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        widget.environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty || _catalogIndex >= catalogs.length) return;

    configuredGateways = await ConfiguredGatewayService.getInstance()
        .listConfiguredGateways(widget.environment,
            orgs[_organizationIndex].name!, catalogs[_catalogIndex].name,
            queryParameters: "fields=name&fields=title");
    if (configuredGateways.isEmpty ||
        _configuredGatewayIndex >= configuredGateways.length) return;

    await _loadGlobalPolicies(
      orgs[_organizationIndex].name!,
      catalogs[_catalogIndex].name,
      configuredGateways[_configuredGatewayIndex].name,
    );
    setState(() {
      _isLoading = false;
    });
  }

  bool _areDataAvailable() {
    return orgs.isNotEmpty &&
        catalogs.isNotEmpty &&
        configuredGateways.isNotEmpty;
  }

  Future<void> _loadGlobalPolicies(String organizationName, String catalogName,
      String configuredGatewayName) async {
    final globalPoliciesService = GlobalPoliciesService.getInstance();
    final prehookGlobalPolicy =
        await globalPoliciesService.getPrehookGlobalPolicy(
      widget.environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: "fields=name&fields=global_policy_url",
      ignoreUIError: true,
    );
    final posthookGlobalPolicy =
        await globalPoliciesService.getPosthookGlobalPolicy(
      widget.environment,
      organizationName,
      catalogName,
      configuredGatewayName,
      queryParameters: "fields=name&fields=global_policy_url",
      ignoreUIError: true,
    );
    final errorGlobalPolicy = await globalPoliciesService.getErrorGlobalPolicy(
      widget.environment,
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
      widget.environment,
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
      return _CustomGlobalPolicyMeta(type, globalPolicy);
    }).toList();
  }

  Future<void> _loadDataLogic() async {
    orgs = await OrganizationsService.getInstance().listOrgs(widget.environment,
        queryParameters: "fields=name&fields=title&fields=owner_url");
    if (orgs.isEmpty) return;

    catalogs = await CatalogsService.getInstance().listCatalogs(
        widget.environment, orgs[0].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty) return;

    configuredGateways = await ConfiguredGatewayService.getInstance()
        .listConfiguredGateways(
            widget.environment, orgs[0].name!, catalogs[0].name,
            queryParameters: "fields=name&fields=title");
    if (configuredGateways.isEmpty) return;

    await _loadGlobalPolicies(
        orgs[0].name!, catalogs[0].name, configuredGateways[0].name);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadDataLogic();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData().then((value) => null);
  }

  Future<void> _applyOrganizationChanges() async {
    _catalogIndex = 0;
    _configuredGatewayIndex = 0;
    catalogs = await CatalogsService.getInstance().listCatalogs(
        widget.environment, orgs[_organizationIndex].name!,
        queryParameters: "fields=name&fields=title");
    if (catalogs.isEmpty) return;

    configuredGateways = await ConfiguredGatewayService.getInstance()
        .listConfiguredGateways(widget.environment,
            orgs[_organizationIndex].name!, catalogs[0].name,
            queryParameters: "fields=name&fields=title");
  }

  Future<void> _applyCatalogChanges() async {
    _configuredGatewayIndex = 0;
    configuredGateways = await ConfiguredGatewayService.getInstance()
        .listConfiguredGateways(widget.environment,
            orgs[_organizationIndex].name!, catalogs[_catalogIndex].name,
            queryParameters: "fields=name&fields=title");
  }

  void _applyChange(ChangeType changeType) async {
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
  }

  List<ComboBoxItem<int>> _buildOrgsMenu() {
    List<ComboBoxItem<int>> orgsMenu = [];
    for (int i = 0; i < orgs.length; i++) {
      orgsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          orgs[i].title!,
        ),
      ));
    }
    return orgsMenu;
  }

  List<ComboBoxItem<int>> _buildCatalogsMenu() {
    List<ComboBoxItem<int>> catalogsMenu = [];
    for (int i = 0; i < catalogs.length; i++) {
      catalogsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          catalogs[i].title!,
        ),
      ));
    }
    return catalogsMenu;
  }

  List<ComboBoxItem<int>> _buildConfiguredGatewaysMenu() {
    List<ComboBoxItem<int>> configuredGatewaysMenu = [];
    for (int i = 0; i < configuredGateways.length; i++) {
      configuredGatewaysMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          configuredGateways[i].title!,
        ),
      ));
    }
    return configuredGatewaysMenu;
  }

  Widget? mapGlobalPolicyTypeToIcon(GlobalPolicyType type) {
    switch (type) {
      case GlobalPolicyType.none:
        return null;
      case GlobalPolicyType.input:
        return Tooltip(
          message: "Assigned as Prehook Global Policy",
          child: Image.asset("assets/icons/input-64.png", width: 32),
        );
      case GlobalPolicyType.output:
        return Tooltip(
          message: "Assigned as Posthook Global Policy",
          child: Image.asset("assets/icons/output-64.png", width: 32),
        );
      case GlobalPolicyType.inputOutput:
        return Tooltip(
          message: "Assigned as Prehook & Posthook Global Policy",
          child: Image.asset("assets/icons/input-ouput-64.png", width: 32),
        );
      case GlobalPolicyType.error:
        return Tooltip(
          message: "Assigned as Error Global Policy",
          child: Image.asset("assets/icons/error-handling-64.png", width: 32),
        );
    }
  }

  Future<void> handleGlobalPolicyAssignment(
      int globalPolicyIndex, GlobalPolicyType type) async {
    setState(() => _isLoading = true);
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
        environment: widget.environment,
        organizationName: orgs[_organizationIndex].name!,
        catalogName: catalogs[_catalogIndex].name,
        configuredGatewayName: configuredGateways[_configuredGatewayIndex].name,
        globalPolicyUrl:
            globalPolicies[globalPolicyIndex].globalPolicyMeta.url!);
    if (isAssigned) {
      globalPolicies[globalPolicyIndex].globalPolicyType = type;
    }
    setState(() => _isLoading = false);
  }

  Future<void> handleGlobalPolicyUnassignment(
      int globalPolicyIndex, GlobalPolicyType type) async {
    setState(() => _isLoading = true);
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
      environment: widget.environment,
      organizationName: orgs[_organizationIndex].name!,
      catalogName: catalogs[_catalogIndex].name,
      configuredGatewayName: configuredGateways[_configuredGatewayIndex].name,
    );
    if (isAssigned) {
      globalPolicies[globalPolicyIndex].globalPolicyType =
          GlobalPolicyType.none;
    }
    setState(() => _isLoading = false);
  }

  Future<void> download(String name, String version, String code) async {
    final outputFilePath = await FilePicker.platform.saveFile(
      fileName: '${name}_$version.yaml',
      dialogTitle: 'Please select an output file:',
    );
    if (outputFilePath != null) {
      bool isConfirmed = true;
      final file = File(outputFilePath);
      BuildContext? context = NavigationService.navigatorKey.currentContext;
      if (file.existsSync() && context != null && context.mounted) {
        isConfirmed = await showDialog<bool>(
              barrierDismissible: true,
              context: context,
              builder: (ctx) {
                return ConfirmationPopUp(
                    "Do you want to overwrite ${basename(outputFilePath)}");
              },
            ) ??
            false;
      }
      if (isConfirmed) {
        file.writeAsString(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return _isLoading
        ? const Loader()
        : Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text("Organization: "),
                        ComboBox<int>(
                          value: _organizationIndex,
                          items: _buildOrgsMenu(),
                          onChanged: (index) => setState(() {
                            _organizationIndex = index!;
                            _applyChange(ChangeType.organization);
                          }),
                        ),
                        const SizedBox(width: 10),
                        const Text("Catalog: "),
                        ComboBox<int>(
                          value: _catalogIndex,
                          items: _buildCatalogsMenu(),
                          onChanged: (index) => setState(() {
                            _catalogIndex = index!;
                            _applyChange(ChangeType.catalog);
                          }),
                        ),
                        const SizedBox(width: 10),
                        const Text("Gateway: "),
                        ComboBox<int>(
                          value: _configuredGatewayIndex,
                          items: _buildConfiguredGatewaysMenu(),
                          onChanged: (index) => setState(() {
                            _configuredGatewayIndex = index!;
                            _applyChange(ChangeType.configuredGateway);
                          }),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(FluentIcons.upload),
                          onPressed: () async {
                            if (!_areDataAvailable()) return;
                            final isUploaded = await showDialog<bool>(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (ctx) {
                                    return UploadGlobalPolicyScreen(
                                      environment: widget.environment,
                                      organizationName:
                                          orgs[_organizationIndex].name!,
                                      catalogName: catalogs[_catalogIndex].name,
                                      configuredGatewayName: configuredGateways[
                                              _configuredGatewayIndex]
                                          .name,
                                    );
                                  },
                                ) ??
                                false;
                            if (isUploaded) _refreshData();
                          },
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(FluentIcons.refresh),
                          onPressed: () => _refreshData(),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  width: screenWidth,
                  height: 500,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black.withOpacity(0.2),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ListView.builder(
                      itemCount: globalPolicies.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          leading: mapGlobalPolicyTypeToIcon(
                            globalPolicies[index].globalPolicyType,
                          ),
                          tileColor:
                              ButtonState.all(Colors.black.withOpacity(0.4)),
                          title: Text(
                              globalPolicies[index].globalPolicyMeta.title ??
                                  ""),
                          subtitle: Text(
                              "${globalPolicies[index].globalPolicyMeta.name}:${globalPolicies[index].globalPolicyMeta.version}"),
                          trailing: Row(
                            children: [
                              Button(
                                child: globalPolicies[index].globalPolicyType ==
                                        GlobalPolicyType.none
                                    ? const Text("Assign")
                                    : const Text("Unassign"),
                                onPressed: () async {
                                  if (globalPolicies[index].globalPolicyType !=
                                      GlobalPolicyType.none) {
                                    handleGlobalPolicyUnassignment(
                                      index,
                                      globalPolicies[index].globalPolicyType,
                                    );
                                  } else {
                                    final choiceIndex = await showDialog<int>(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (ctx) {
                                            return const ChoicesPopUp(
                                                "Select Global Policy Type", [
                                              "Pre-request global policy",
                                              "Post-response global policy",
                                              "Error global policy",
                                            ]);
                                          },
                                        ) ??
                                        -1;
                                    if (choiceIndex >= 0) {
                                      GlobalPolicyType type = [
                                        GlobalPolicyType.input,
                                        GlobalPolicyType.output,
                                        GlobalPolicyType.error
                                      ][choiceIndex];
                                      handleGlobalPolicyAssignment(index, type);
                                    }
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              Tooltip(
                                message: "View Global Policy",
                                child: IconButton(
                                  icon: const Icon(FluentIcons.view),
                                  onPressed: () async {
                                    final version = globalPolicies[index]
                                        .globalPolicyMeta
                                        .version!;
                                    final code = await GlobalPoliciesService
                                            .getInstance()
                                        .getGlobalPolicyYAML(
                                            environment: widget.environment,
                                            organizationName:
                                                orgs[_organizationIndex].name!,
                                            catalogName:
                                                catalogs[_catalogIndex].name,
                                            configuredGatewayName:
                                                configuredGateways[
                                                        _configuredGatewayIndex]
                                                    .name,
                                            globalPolicyName:
                                                globalPolicies[index]
                                                    .globalPolicyMeta
                                                    .name,
                                            globalPolicyVersion: version);
                                    if (context.mounted) {
                                      showDialog(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (ctx) {
                                            return YamlViewer(
                                              title: globalPolicies[index]
                                                  .globalPolicyMeta
                                                  .title!,
                                              version: version,
                                              code: code,
                                            );
                                          });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Tooltip(
                                message: "Edit Global Policy",
                                child: IconButton(
                                  icon: const Icon(FluentIcons.page_edit),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 10),
                              Tooltip(
                                message: "Download Global Policy",
                                child: IconButton(
                                  icon: const Icon(FluentIcons.download),
                                  onPressed: () async {
                                    final name = globalPolicies[index]
                                        .globalPolicyMeta
                                        .name;
                                    final version = globalPolicies[index]
                                        .globalPolicyMeta
                                        .version!;
                                    final code = await GlobalPoliciesService
                                            .getInstance()
                                        .getGlobalPolicyYAML(
                                      environment: widget.environment,
                                      organizationName:
                                          orgs[_organizationIndex].name!,
                                      catalogName: catalogs[_catalogIndex].name,
                                      configuredGatewayName: configuredGateways[
                                              _configuredGatewayIndex]
                                          .name,
                                      globalPolicyName: name,
                                      globalPolicyVersion: version,
                                    );
                                    print(name);
                                    print(version);
                                    await download(name, version, code);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Tooltip(
                                message: "Delete Global Policy",
                                child: IconButton(
                                  icon: const Icon(FluentIcons.delete),
                                  onPressed: () async {
                                    final isConfirmed = await showDialog<bool>(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (ctx) {
                                            return const ConfirmationPopUp(
                                                "Do you want to delete this global policy?");
                                          },
                                        ) ??
                                        false;
                                    if (isConfirmed) {
                                      setState(() => _isLoading = true);
                                      final isDeleted =
                                          await GlobalPoliciesService
                                                  .getInstance()
                                              .deleteGlobalPolicy(
                                        environment: widget.environment,
                                        organizationName:
                                            orgs[_organizationIndex].name!,
                                        catalogName:
                                            catalogs[_catalogIndex].name,
                                        configuredGatewayName:
                                            configuredGateways[
                                                    _configuredGatewayIndex]
                                                .name,
                                        globalPolicyName: globalPolicies[index]
                                            .globalPolicyMeta
                                            .name,
                                        globalPolicyVersion:
                                            globalPolicies[index]
                                                .globalPolicyMeta
                                                .version!,
                                      );
                                      if (isDeleted) {
                                        globalPolicies.removeAt(index);
                                      }
                                      setState(() => _isLoading = false);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                )
              ],
            ),
          );
  }
}
