import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:path/path.dart';

import '../controllers/global_policies_controller.dart';
import './upload_global_policy_screen.dart';
import '../global_configurations.dart';
import '../models/environment.dart';
import '../navigation_service.dart';
import '../widgets/choices_pop_up.dart';
import '../widgets/confirmation_pop_up.dart';
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

class _GlobalPoliciesSubScreenState extends State<GlobalPoliciesSubScreen> {
  late final GlobalPoliciesController _globalPoliciesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _globalPoliciesController = GlobalPoliciesController(widget.environment);
    _loadData().then((value) => null);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _globalPoliciesController.loadData();
    setState(() => _isLoading = false);
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _globalPoliciesController.refreshData();
    setState(() => _isLoading = false);
  }

  void _applyChange(ChangeType changeType) async {
    setState(() => _isLoading = true);
    await _globalPoliciesController.applyChange(changeType);
    setState(() => _isLoading = false);
  }

  Future<void> _handleGlobalPolicyAssignment(
      int globalPolicyIndex, GlobalPolicyType type) async {
    setState(() => _isLoading = true);
    await _globalPoliciesController.handleGlobalPolicyAssignment(
        globalPolicyIndex, type);
    setState(() => _isLoading = false);
  }

  Future<void> _handleGlobalPolicyUnassignment(
      int globalPolicyIndex, GlobalPolicyType type) async {
    setState(() => _isLoading = true);
    await _globalPoliciesController.handleGlobalPolicyUnassignment(
        globalPolicyIndex, type);
    setState(() => _isLoading = false);
  }

  List<ComboBoxItem<int>> _buildOrgsMenu() {
    List<ComboBoxItem<int>> orgsMenu = [];
    for (int i = 0; i < _globalPoliciesController.orgs.length; i++) {
      orgsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          _globalPoliciesController.orgs[i].title!,
        ),
      ));
    }
    return orgsMenu;
  }

  List<ComboBoxItem<int>> _buildCatalogsMenu() {
    List<ComboBoxItem<int>> catalogsMenu = [];
    for (int i = 0; i < _globalPoliciesController.catalogs.length; i++) {
      catalogsMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          _globalPoliciesController.catalogs[i].title!,
        ),
      ));
    }
    return catalogsMenu;
  }

  List<ComboBoxItem<int>> _buildConfiguredGatewaysMenu() {
    List<ComboBoxItem<int>> configuredGatewaysMenu = [];
    for (int i = 0;
        i < _globalPoliciesController.configuredGateways.length;
        i++) {
      configuredGatewaysMenu.add(ComboBoxItem(
        value: i,
        child: ResponsiveText(
          _globalPoliciesController.configuredGateways[i].title!,
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
                          value: _globalPoliciesController.organizationIndex,
                          items: _buildOrgsMenu(),
                          onChanged: (index) => setState(() {
                            _globalPoliciesController.organizationIndex =
                                index!;
                            _applyChange(ChangeType.organization);
                          }),
                        ),
                        const SizedBox(width: 10),
                        const Text("Catalog: "),
                        ComboBox<int>(
                          value: _globalPoliciesController.catalogIndex,
                          items: _buildCatalogsMenu(),
                          onChanged: (index) => setState(() {
                            _globalPoliciesController.catalogIndex = index!;
                            _applyChange(ChangeType.catalog);
                          }),
                        ),
                        const SizedBox(width: 10),
                        const Text("Gateway: "),
                        ComboBox<int>(
                          value:
                              _globalPoliciesController.configuredGatewayIndex,
                          items: _buildConfiguredGatewaysMenu(),
                          onChanged: (index) => setState(() {
                            _globalPoliciesController.configuredGatewayIndex =
                                index!;
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
                            if (!_globalPoliciesController.areDataAvailable()) {
                              return;
                            }
                            final isUploaded = await showDialog<bool>(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (ctx) {
                                    return Center(
                                      child: SizedBox(
                                        width: screenWidth * 0.5,
                                        child: UploadGlobalPolicyScreen(
                                          environment: widget.environment,
                                          organizationName:
                                              _globalPoliciesController
                                                  .orgs[
                                                      _globalPoliciesController
                                                          .organizationIndex]
                                                  .name!,
                                          catalogName: _globalPoliciesController
                                              .catalogs[
                                                  _globalPoliciesController
                                                      .catalogIndex]
                                              .name,
                                          configuredGatewayName:
                                              _globalPoliciesController
                                                  .configuredGateways[
                                                      _globalPoliciesController
                                                          .configuredGatewayIndex]
                                                  .name,
                                        ),
                                      ),
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
                    itemCount: _globalPoliciesController.globalPolicies.length,
                    itemBuilder: (ctx, index) {
                      return ListTile(
                        leading: mapGlobalPolicyTypeToIcon(
                          _globalPoliciesController
                              .globalPolicies[index].globalPolicyType,
                        ),
                        tileColor:
                            ButtonState.all(Colors.black.withOpacity(0.4)),
                        title: Text(_globalPoliciesController
                                .globalPolicies[index].globalPolicyMeta.title ??
                            ""),
                        subtitle: SelectableText(
                            "${_globalPoliciesController.globalPolicies[index].globalPolicyMeta.name}:${_globalPoliciesController.globalPolicies[index].globalPolicyMeta.version}"),
                        trailing: Row(
                          children: [
                            Button(
                              child: _globalPoliciesController
                                          .globalPolicies[index]
                                          .globalPolicyType ==
                                      GlobalPolicyType.none
                                  ? const Text("Assign")
                                  : const Text("Unassign"),
                              onPressed: () async {
                                if (_globalPoliciesController
                                        .globalPolicies[index]
                                        .globalPolicyType !=
                                    GlobalPolicyType.none) {
                                  _handleGlobalPolicyUnassignment(
                                    index,
                                    _globalPoliciesController
                                        .globalPolicies[index].globalPolicyType,
                                  );
                                } else {
                                  final choiceIndex = await showDialog<int>(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (ctx) {
                                          return const ChoicesPopUp(
                                            "Select Global Policy Type",
                                            [
                                              "Prehook",
                                              "Posthook",
                                              "Error",
                                            ],
                                          );
                                        },
                                      ) ??
                                      -1;
                                  if (choiceIndex >= 0) {
                                    GlobalPolicyType type = [
                                      GlobalPolicyType.input,
                                      GlobalPolicyType.output,
                                      GlobalPolicyType.error
                                    ][choiceIndex];
                                    _handleGlobalPolicyAssignment(index, type);
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
                                  final version = _globalPoliciesController
                                      .globalPolicies[index]
                                      .globalPolicyMeta
                                      .version!;
                                  final code = await _globalPoliciesController
                                      .getGlobalPolicy(index);
                                  if (context.mounted) {
                                    showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (ctx) {
                                        return YamlViewer(
                                          title: _globalPoliciesController
                                              .globalPolicies[index]
                                              .globalPolicyMeta
                                              .title!,
                                          version: version,
                                          code: code,
                                        );
                                      },
                                    );
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
                                  final name = _globalPoliciesController
                                      .globalPolicies[index]
                                      .globalPolicyMeta
                                      .name;
                                  final version = _globalPoliciesController
                                      .globalPolicies[index]
                                      .globalPolicyMeta
                                      .version!;
                                  final code = await _globalPoliciesController
                                      .getGlobalPolicy(index);
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
                                        await _globalPoliciesController
                                            .deleteGlobalPolicy(index);
                                    if (isDeleted) {
                                      _globalPoliciesController.globalPolicies
                                          .removeAt(index);
                                    }
                                    setState(() => _isLoading = false);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
  }
}
