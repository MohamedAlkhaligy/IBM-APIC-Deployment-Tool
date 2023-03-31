import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';

import '../models/environment.dart';
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
  int _currentIndex = 0;
  bool _isHighlighted = false;
  final String _message = 'Drop Global Policy Here!';

  Widget uploadSingleFileWindow() {
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
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
                      } else if (!RegExp("^.*.(yaml|yml)\$")
                          .hasMatch(detail.files.first.name.toLowerCase())) {
                        ErrorHandlingUtilities.instance
                            .showPopUpError("Only yaml files are supported!");
                      } else {
                        String globalPolicyYAML =
                            await File(detail.files.first.path).readAsString();
                        bool isUploaded =
                            await GlobalPoliciesService.getInstance()
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
                    children: [
                      const Icon(FluentIcons.cloud_upload,
                          size: 80, color: Colors.white),
                      Text(
                        _message,
                        style: const TextStyle(color: Colors.white),
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
                allowedExtensions: ["yaml", "yml"],
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

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(25),
      child: TabView(
        tabs: [
          Tab(
            text: const Text('Complete'),
            body: uploadSingleFileWindow(),
          )
        ],
        currentIndex: _currentIndex,
        onChanged: (index) => setState(() => _currentIndex = index),
        tabWidthBehavior: TabWidthBehavior.equal,
        closeButtonVisibility: CloseButtonVisibilityMode.never,
        showScrollButtons: true,
        wheelScroll: false,
      ),
    );
  }
}
