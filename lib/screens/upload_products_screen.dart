import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/controllers/products_controller.dart';
import 'package:ibm_apic_dt/widgets/loader.dart';

class UploadProductsScreen extends StatefulWidget {
  final ProductController _productController;

  const UploadProductsScreen(this._productController, {super.key});

  @override
  State<UploadProductsScreen> createState() => _UploadProductsScreenState();
}

class _UploadProductsScreenState extends State<UploadProductsScreen> {
  bool _isHighlighted = false;
  bool _isPublishing = false;
  final _message = 'Drop products here';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return _isPublishing
        ? const Loader()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: _isHighlighted ? Colors.grey[40] : Colors.grey[100],
                ),
                width: screenWidth * 0.95,
                height: screenHeight * 0.65,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                          ),
                          color: Colors.grey,
                        ),
                        child: IconButton(
                            icon: Icon(
                              FluentIcons.chrome_close,
                              size: 25,
                              color: Colors.red.darkest,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            }),
                      ),
                    ),
                    DropTarget(
                      onDragDone: (detail) async {
                        setState(() => _isPublishing = true);
                        bool areFilesLoaded = await widget._productController
                            .loadProducts(detail.files);
                        if (context.mounted) {
                          Navigator.of(context).pop(areFilesLoaded);
                        }
                        setState(() => _isPublishing = false);
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
                          const Icon(FluentIcons.bulk_upload,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    style: ButtonStyle(
                      padding: ButtonState.all(const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25)),
                    ),
                    child: const Text('Pick Files'),
                    onPressed: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                        type: FileType.custom,
                        allowedExtensions: ["yaml", "yml"],
                      );

                      bool areFilesLoaded = false;
                      if (result != null) {
                        setState(() => _isPublishing = true);
                        areFilesLoaded =
                            await widget._productController.loadProducts(
                          result.files
                              .map((file) => XFile(file.path!))
                              .toList(),
                        );
                        setState(() => _isPublishing = false);
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(areFilesLoaded);
                      }
                    },
                  ),
                  const SizedBox(width: 25),
                  const Text("OR"),
                  const SizedBox(width: 25),
                  Button(
                    style: ButtonStyle(
                      padding: ButtonState.all(const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 25)),
                    ),
                    child: const Text('Pick Folder'),
                    onPressed: () async {
                      final dirPath =
                          await FilePicker.platform.getDirectoryPath();
                      List<XFile> files = [];
                      bool areFilesLoaded = false;
                      if (dirPath != null) {
                        setState(() => _isPublishing = true);
                        final dir = Directory(dirPath);
                        await for (final entity
                            in dir.list(recursive: true, followLinks: false)) {
                          if (FileSystemEntity.isFileSync(entity.path)) {
                            files.add(XFile(entity.path));
                          }
                        }

                        areFilesLoaded =
                            await widget._productController.loadProducts(files);
                        setState(() => _isPublishing = false);
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop(areFilesLoaded);
                      }
                    },
                  ),
                ],
              )
            ],
          );
  }
}
