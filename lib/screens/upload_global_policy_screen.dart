import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:ibm_apic_dt/models/global_policies/global_policy.dart';

import '../global_configurations.dart';
import '../models/environment.dart';
import '../models/products/openapi.dart';
import '../services/global_policies_service.dart';
import '../utilities/error_handling_utilities.dart';
import '../widgets/confirmation_pop_up.dart';

class UploadGlobalPolicyScreen extends StatefulWidget {
  final Environment environment;
  final String organizationName;
  final String catalogName;
  final String configuredGatewayName;

  const UploadGlobalPolicyScreen({
    required this.environment,
    required this.organizationName,
    required this.catalogName,
    required this.configuredGatewayName,
    super.key,
  });

  @override
  State<UploadGlobalPolicyScreen> createState() =>
      _UploadGlobalPolicyScreenState();
}

mixin PostFrameMixin<T extends StatefulWidget> on State<T> {
  void postFrame(void Function() callback) =>
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          // Execute callback if page is mounted
          callback();
        },
      );
}

class _UploadGlobalPolicyScreenState extends State<UploadGlobalPolicyScreen>
    with PostFrameMixin {
  final TextEditingController globalPolicyVersionController =
          TextEditingController(text: "1.0.0"),
      titleController = TextEditingController(),
      nameController = TextEditingController(),
      versionController = TextEditingController();
  late OpenAPI openAPI;
  late File openAPIFile;

  int _currentIndex = 0;
  bool _isHighlighted = false, _isAPILoaded = false, _isCatchesOnly = false;

  @override
  void dispose() {
    globalPolicyVersionController.dispose();
    titleController.dispose();
    nameController.dispose();
    versionController.dispose();
    super.dispose();
  }

  Widget uploadGlobalPolicyFileWindow(int tabIndex) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: _isHighlighted ? Colors.grey[40] : Colors.grey[100],
            ),
            height: screenHeight * 0.75,
            child: Stack(
              children: [
                DropTarget(
                  onDragDone: (detail) async {
                    if (tabIndex != _currentIndex) return;
                    final isConfirmed = await showDialog<bool>(
                          barrierDismissible: true,
                          context: context,
                          builder: (ctx) {
                            return const ConfirmationPopUp(
                                "Do you want to upload this global policy?");
                          },
                        ) ??
                        false;
                    if (isConfirmed) {
                      if (await FileSystemEntity.isDirectory(
                          detail.files.first.path)) {
                        ErrorHandlingUtilities.instance.showPopUpError(
                            "Please, upload single file at a time!");
                      } else if (!RegExp("^.*.(yaml|yml|json)\$")
                          .hasMatch(detail.files.first.name.toLowerCase())) {
                        ErrorHandlingUtilities.instance
                            .showPopUpError("Only yaml files are supported!");
                      } else {
                        String globalPolicyAsString =
                            await File(detail.files.first.path).readAsString();
                        bool isUploaded =
                            await GlobalPoliciesService.getInstance()
                                .uploadGlobalPolicy(globalPolicyAsString,
                                    environment: widget.environment,
                                    organizationName: widget.organizationName,
                                    catalogName: widget.catalogName,
                                    configuredGatewayName:
                                        widget.configuredGatewayName,
                                    isJson: RegExp("^.*.(json)\$").hasMatch(
                                        detail.files.first.name.toLowerCase()));
                        if (context.mounted) {
                          Navigator.of(context).pop(isUploaded);
                        }
                      }
                    }
                  },
                  onDragEntered: (details) =>
                      setState(() => _isHighlighted = true),
                  onDragExited: (details) =>
                      setState(() => _isHighlighted = false),
                  child: Container(),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(FluentIcons.cloud_upload,
                          size: 80, color: Colors.white),
                      Text(
                        'Drop Global Policy Here!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Button(
            style: ButtonStyle(
              padding: ButtonState.all(
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 25)),
            ),
            child: const Text('Pick file'),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ["yaml", "yml", "json"],
                lockParentWindow: true,
              );
              if (result != null) {
                String globalPolicyYAML =
                    await File(result.files.single.path!).readAsString();
                bool isUploaded = await GlobalPoliciesService.getInstance()
                    .uploadGlobalPolicy(
                  globalPolicyYAML,
                  environment: widget.environment,
                  organizationName: widget.organizationName,
                  catalogName: widget.catalogName,
                  configuredGatewayName: widget.configuredGatewayName,
                );
                if (context.mounted) {
                  Navigator.of(context).pop(isUploaded);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  bool areFieldsFilled() {
    return nameController.text.isNotEmpty &&
        versionController.text.isNotEmpty &&
        titleController.text.isNotEmpty &&
        globalPolicyVersionController.text.isNotEmpty;
  }

  Future<void> loadOpenAPIFile(String openAPIFilePath) async {
    try {
      openAPIFile = File(openAPIFilePath);
      openAPI = await OpenAPI.loadOpenAPI(openAPIFile);

      if (nameController.text.isEmpty) {
        nameController.text = openAPI.info.name;
      }
      if (versionController.text.isEmpty) {
        versionController.text = openAPI.info.version;
      }

      if (titleController.text.isEmpty) {
        titleController.text = openAPI.info.title ?? openAPI.info.name;
      }

      setState(() => _isAPILoaded = true);
    } catch (error, traceStack) {
      GlobalConfigurations.logger.e(
        "UploadGlobalPolicyScreen:loadOpenAPIFile",
        error,
        traceStack,
      );
      await ErrorHandlingUtilities.instance.showPopUpError(
          "Cannot be loaded. Make sure the specified file is an API!\nError: $error");
    }
  }

  Future<void> publishGlobalPolicy() async {
    if (!areFieldsFilled()) {
      ErrorHandlingUtilities.instance
          .showPopUpError("Please fill in all fields!");
      return;
    }
    GlobalPolicy globalPolicy = GlobalPolicy(
        globalPolicy: globalPolicyVersionController.text,
        info: Info(
            name: nameController.text,
            title: titleController.text,
            version: versionController.text),
        gateways: ["datapower-api-gateway"],
        assembly: Assembly(
          executeList: _isCatchesOnly
              ? null
              : openAPI.ibmConfiguration.assembly.executeList ?? [],
          catchList: openAPI.ibmConfiguration.assembly.catchList ?? [],
        ));

    bool isUploaded =
        await GlobalPoliciesService.getInstance().uploadGlobalPolicy(
      json.encode(globalPolicy),
      environment: widget.environment,
      organizationName: widget.organizationName,
      catalogName: widget.catalogName,
      configuredGatewayName: widget.configuredGatewayName,
      isJson: true,
    );
    if (context.mounted) {
      Navigator.of(context).pop(isUploaded);
    }
  }

  Widget uploadGlobalPolicyFromAssemblyFlowWindow(int tabIndex) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Publish Global Policy From An Assembly Flow",
              style: TextStyle(fontSize: 24)),
          TextBox(
            header: "global-policy",
            controller: globalPolicyVersionController,
            onSubmitted: (_) async => await publishGlobalPolicy(),
          ),
          const SizedBox(height: 10),
          TextBox(
            header: "info.title",
            controller: titleController,
            onSubmitted: (_) async => await publishGlobalPolicy(),
          ),
          const SizedBox(height: 10),
          TextBox(
            header: "info.name",
            controller: nameController,
            onSubmitted: (_) async => await publishGlobalPolicy(),
          ),
          const SizedBox(height: 10),
          TextBox(
            header: "info.version",
            controller: versionController,
            onSubmitted: (_) async => await publishGlobalPolicy(),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Checkbox(
              checked: _isCatchesOnly,
              onChanged: (value) =>
                  setState(() => _isCatchesOnly = value ?? false),
              content: const Text(
                "Include catches only (For error global policies)",
              ),
            ),
          ),
          const SizedBox(height: 10),
          !_isAPILoaded
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: _isHighlighted ? Colors.grey[40] : Colors.grey[100],
                  ),
                  height: screenHeight * 0.3,
                  child: Stack(
                    children: [
                      DropTarget(
                        onDragDone: (detail) async {
                          // DropTarget is active in all tabs, so we have to refuse data from other tabs
                          if (tabIndex != _currentIndex) return;
                          if (await FileSystemEntity.isDirectory(
                              detail.files.first.path)) {
                            ErrorHandlingUtilities.instance.showPopUpError(
                                "Please, upload single file at a time!");
                          } else if (!OpenAPI.isExtensionSupported(
                              detail.files.first.name.toLowerCase())) {
                            ErrorHandlingUtilities.instance.showPopUpError(
                                "Only yaml files are supported!");
                          } else {
                            await loadOpenAPIFile(detail.files.first.path);
                          }
                        },
                        onDragEntered: (details) =>
                            setState(() => _isHighlighted = true),
                        onDragExited: (details) =>
                            setState(() => _isHighlighted = false),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(FluentIcons.cloud_upload,
                                  size: 80, color: Colors.white),
                              Text(
                                "Drop API Here!",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : SizedBox(
                  height: screenHeight * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        openAPIFile.path,
                      ),
                      const SizedBox(height: 10),
                      IconButton(
                        onPressed: () {
                          setState(() => _isAPILoaded = false);
                        },
                        icon: Icon(
                          FluentIcons.clear,
                          color: Colors.red.lightest,
                          size: 18,
                        ),
                      )
                    ],
                  ),
                ),
          const SizedBox(height: 10),
          !_isAPILoaded
              ? Button(
                  style: ButtonStyle(
                    padding: ButtonState.all(const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 25)),
                  ),
                  child: const Text('Pick file'),
                  onPressed: () async {
                    final filePickerResult =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ["yaml", "yml", "json"],
                      lockParentWindow: true,
                    );
                    if (filePickerResult != null) {
                      await loadOpenAPIFile(
                          filePickerResult.files.single.path!);
                    }
                  },
                )
              : Button(
                  child: const Text('Submit'),
                  onPressed: () async => await publishGlobalPolicy(),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(25),
      child: TabView(
        tabs: [
          Tab(
            text: const Text('Global Policy'),
            body: uploadGlobalPolicyFileWindow(0),
          ),
          Tab(
            text: const Text('Assembly Flow'),
            body: uploadGlobalPolicyFromAssemblyFlowWindow(1),
          )
        ],
        currentIndex: _currentIndex,
        onChanged: (index) {
          setState(() => _currentIndex = index);
        },
        tabWidthBehavior: TabWidthBehavior.equal,
        closeButtonVisibility: CloseButtonVisibilityMode.never,
        showScrollButtons: true,
        wheelScroll: false,
      ),
    );
  }
}
