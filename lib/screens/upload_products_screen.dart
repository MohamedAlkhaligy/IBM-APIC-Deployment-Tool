import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:ibm_apic_dt/controllers/products_controller.dart';

class UploadProductsScreen extends StatefulWidget {
  final ProductController _productController;

  const UploadProductsScreen(this._productController, {super.key});

  @override
  State<UploadProductsScreen> createState() => _UploadProductsScreenState();
}

class _UploadProductsScreenState extends State<UploadProductsScreen> {
  bool _isHighlighted = false;
  final _message = 'Drop products here';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
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
              DropTarget(
                onDragDone: (detail) async {
                  bool areFilesLoaded = await widget._productController
                      .loadProducts(detail.files);
                  if (context.mounted) {
                    Navigator.of(context).pop(areFilesLoaded);
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
                padding: ButtonState.all(
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25)),
              ),
              child: const Text('Pick Files'),
              onPressed: () async {},
            ),
            const SizedBox(width: 25),
            const Text("OR"),
            const SizedBox(width: 25),
            Button(
              style: ButtonStyle(
                padding: ButtonState.all(
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25)),
              ),
              child: const Text('Pick Folder'),
              onPressed: () async {},
            ),
          ],
        )
      ],
    );
  }
}
