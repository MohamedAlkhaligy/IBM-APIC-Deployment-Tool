// import 'dart:convert';
// import 'dart:html';

import 'package:fluent_ui/fluent_ui.dart';

import '../global_configurations.dart';
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

enum MediaType { yaml, json }

enum GlobalPolicyType { none, input, output, both }

class _CustomGlobalPolicyMeta {
  GlobalPolicyType globalPolicyType;
  final GlobalPolicyMeta globalPolicyMeta;

  _CustomGlobalPolicyMeta(this.globalPolicyType, this.globalPolicyMeta);
}

class _GlobalPoliciesSubScreenState extends State<GlobalPoliciesSubScreen> {
  int _organizationIndex = 0, _catalogIndex = 0, _configuredGatewayIndex = 0;
  bool _isLoading = false;
  MediaType mediaType = MediaType.yaml;
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

    final prehookGlobalPolicyURL = (prehookGlobalPolicy != null)
        ? prehookGlobalPolicy.globalPolicyURL ?? ''
        : '';
    final posthookGlobalPolicyURL = (posthookGlobalPolicy != null)
        ? posthookGlobalPolicy.globalPolicyURL ?? ''
        : '';

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
      }
      if (globalPolicy.url == posthookGlobalPolicyURL) {
        type = (type == GlobalPolicyType.input)
            ? GlobalPolicyType.both
            : GlobalPolicyType.output;
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
        // return const SizedBox(width: 32);
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
      case GlobalPolicyType.both:
        return Tooltip(
          message: "Assigned as Prehook & Posthook Global Policy",
          child: Image.asset("assets/icons/input-ouput-64.png", width: 32),
        );
    }
  }

  Future<void> handlePrehookPolicyAssignment(int globalPolicyIndex) async {
    setState(() => _isLoading = true);
    final globalPoliciesService = GlobalPoliciesService.getInstance();
    final globalPolicyType = globalPolicies[globalPolicyIndex].globalPolicyType;
    if (globalPolicyType == GlobalPolicyType.none ||
        globalPolicyType == GlobalPolicyType.output) {
      bool isAssigned = await globalPoliciesService.assignPrehookGlobalPolicy(
          environment: widget.environment,
          organizationName: orgs[_organizationIndex].name!,
          catalogName: catalogs[_catalogIndex].name,
          configuredGatewayName:
              configuredGateways[_configuredGatewayIndex].name,
          globalPolicyUrl:
              globalPolicies[globalPolicyIndex].globalPolicyMeta.url!);
      if (isAssigned) {
        globalPolicies[globalPolicyIndex].globalPolicyType =
            (globalPolicyType == GlobalPolicyType.output)
                ? GlobalPolicyType.both
                : GlobalPolicyType.input;
      }
    } else {
      bool isUnassigned = await globalPoliciesService.deletePrehookGlobalPolicy(
        environment: widget.environment,
        organizationName: orgs[_organizationIndex].name!,
        catalogName: catalogs[_catalogIndex].name,
        configuredGatewayName: configuredGateways[_configuredGatewayIndex].name,
      );
      if (isUnassigned) {
        globalPolicies[globalPolicyIndex].globalPolicyType =
            (globalPolicyType == GlobalPolicyType.both)
                ? GlobalPolicyType.output
                : GlobalPolicyType.none;
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> handlePosthookPolicyAssignment(int globalPolicyIndex) async {
    setState(() => _isLoading = true);
    final globalPoliciesService = GlobalPoliciesService.getInstance();
    final globalPolicyType = globalPolicies[globalPolicyIndex].globalPolicyType;
    if (globalPolicyType == GlobalPolicyType.none ||
        globalPolicyType == GlobalPolicyType.input) {
      bool isAssigned = await globalPoliciesService.assignPosthookGlobalPolicy(
          environment: widget.environment,
          organizationName: orgs[_organizationIndex].name!,
          catalogName: catalogs[_catalogIndex].name,
          configuredGatewayName:
              configuredGateways[_configuredGatewayIndex].name,
          globalPolicyUrl:
              globalPolicies[globalPolicyIndex].globalPolicyMeta.url!);
      if (isAssigned) {
        globalPolicies[globalPolicyIndex].globalPolicyType =
            (globalPolicyType == GlobalPolicyType.input)
                ? GlobalPolicyType.both
                : GlobalPolicyType.output;
      }
    } else {
      bool isUnassigned =
          await globalPoliciesService.deletePosthookGlobalPolicy(
        environment: widget.environment,
        organizationName: orgs[_organizationIndex].name!,
        catalogName: catalogs[_catalogIndex].name,
        configuredGatewayName: configuredGateways[_configuredGatewayIndex].name,
      );
      if (isUnassigned) {
        globalPolicies[globalPolicyIndex].globalPolicyType =
            (globalPolicyType == GlobalPolicyType.both)
                ? GlobalPolicyType.input
                : GlobalPolicyType.none;
      }
    }
    setState(() => _isLoading = false);
  }

  void download(
    List<int> bytes,
    String? downloadName,
  ) {}

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
                              globalPolicies[index].globalPolicyType),
                          tileColor:
                              ButtonState.all(Colors.black.withOpacity(0.4)),
                          title: Text(
                              globalPolicies[index].globalPolicyMeta.title ??
                                  ""),
                          subtitle:
                              Text(globalPolicies[index].globalPolicyMeta.name),
                          trailing: Row(
                            children: [
                              Button(
                                child: globalPolicies[index].globalPolicyType ==
                                            GlobalPolicyType.input ||
                                        globalPolicies[index]
                                                .globalPolicyType ==
                                            GlobalPolicyType.both
                                    ? const Text("Unassign Prehook")
                                    : const Text("Assign Prehook"),
                                onPressed: () async =>
                                    await handlePrehookPolicyAssignment(index),
                              ),
                              const SizedBox(width: 10),
                              Button(
                                child: globalPolicies[index].globalPolicyType ==
                                            GlobalPolicyType.output ||
                                        globalPolicies[index]
                                                .globalPolicyType ==
                                            GlobalPolicyType.both
                                    ? const Text("Unassign Posthook")
                                    : const Text("Assign Posthook"),
                                onPressed: () async =>
                                    handlePosthookPolicyAssignment(index),
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
                                                code: code);
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
                                    final isConfirmed = await showDialog<bool>(
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (ctx) {
                                            return const ConfirmationPopUp(
                                                "Do you want to download this global policy?");
                                          },
                                        ) ??
                                        false;
                                    if (isConfirmed) {
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
                                        catalogName:
                                            catalogs[_catalogIndex].name,
                                        configuredGatewayName:
                                            configuredGateways[
                                                    _configuredGatewayIndex]
                                                .name,
                                        globalPolicyName: name,
                                        globalPolicyVersion: version,
                                      );
                                      download(code.codeUnits,
                                          '${name}_$version.yaml');
                                    }
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
