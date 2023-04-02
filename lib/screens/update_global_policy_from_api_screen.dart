import 'dart:convert';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/controllers/global_policies_controller.dart';
import 'package:yaml/yaml.dart';

import '../global_configurations.dart';
import '../models/products/openapi.dart';
import '../utilities/error_handling_utilities.dart';
import '../widgets/confirmation_pop_up.dart';

class UpdateGlobalPolicyFromAPIScreen extends StatefulWidget {
  final int _globalPolicyIndex;
  final GlobalPoliciesController _globalPoliciesController;

  const UpdateGlobalPolicyFromAPIScreen(
      this._globalPoliciesController, this._globalPolicyIndex,
      {super.key});

  @override
  State<UpdateGlobalPolicyFromAPIScreen> createState() =>
      _UpdateGlobalPolicyFromAPIScreenFromAPIState();
}

class _UpdateGlobalPolicyFromAPIScreenFromAPIState
    extends State<UpdateGlobalPolicyFromAPIScreen> {
  bool _isHighlighted = false, _isCatchesOnly = false;

  Future<void> updateGlobalPolicy(
      int globalPolicyIndex, String openAPIFilePath) async {
    try {
      final openAPIFile = File(openAPIFilePath);
      final openAPIAsString = await openAPIFile.readAsString();
      final openAPIAsYaml = loadYaml(openAPIAsString);
      final openAPIAsJson = jsonDecode(json.encode(openAPIAsYaml));
      final openAPI = OpenAPI.fromJson(openAPIAsJson);
      if (context.mounted) {
        final globalPolicyMeta = widget._globalPoliciesController
            .globalPolicies[globalPolicyIndex].globalPolicyMeta;
        bool isConfirmed = await showDialog<bool>(
              barrierDismissible: true,
              context: context,
              builder: (ctx) {
                return ConfirmationPopUp(
                    "Do you want to update ${globalPolicyMeta.name}:${globalPolicyMeta.version}");
              },
            ) ??
            false;
        if (isConfirmed) {
          bool isUploaded = await widget._globalPoliciesController
              .updateGlobalPolicy(globalPolicyIndex, _isCatchesOnly, openAPI);
          if (context.mounted) {
            Navigator.of(context).pop(isUploaded);
          }
        }
      }
    } catch (error, traceStack) {
      GlobalConfigurations.logger.e(
        "UpdateGlobalPolicyFromAPI:updateGlobalPolicy",
        error,
        traceStack,
      );
      await ErrorHandlingUtilities.instance.showPopUpError(
          "Cannot be loaded. Make sure the specified file is an API!\nError: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: _isHighlighted ? Colors.grey[40] : Colors.grey[100],
            ),
            height: screenHeight * 0.3,
            child: Stack(
              children: [
                DropTarget(
                  onDragDone: (detail) async {
                    if (await FileSystemEntity.isDirectory(
                        detail.files.first.path)) {
                      ErrorHandlingUtilities.instance.showPopUpError(
                          "Please, upload single file at a time!");
                    } else if (!RegExp("^.*.(yaml|yml)\$")
                        .hasMatch(detail.files.first.name.toLowerCase())) {
                      ErrorHandlingUtilities.instance
                          .showPopUpError("Only yaml files are supported!");
                    } else {
                      await updateGlobalPolicy(
                          widget._globalPolicyIndex, detail.files.first.path);
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
          ),
          const SizedBox(height: 10),
          Button(
            style: ButtonStyle(
              padding: ButtonState.all(
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 25)),
            ),
            child: const Text('Pick file'),
            onPressed: () async {
              final filePickerResult = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ["yaml", "yml"],
                lockParentWindow: true,
              );
              if (filePickerResult != null) {
                await updateGlobalPolicy(widget._globalPolicyIndex,
                    filePickerResult.files.single.path!);
              }
            },
          )
        ],
      ),
    );
  }
}
