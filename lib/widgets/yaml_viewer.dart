import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

class YamlViewer extends StatelessWidget {
  final String title;
  final String version;
  final String code;

  const YamlViewer({
    required this.title,
    required this.version,
    required this.code,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: [
          const Spacer(flex: 1),
          Expanded(
            flex: 6,
            child: Row(
              children: [
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 6,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: SimpleDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      title: Text('$title - $version'),
                      children: [
                        SyntaxView(
                          code: code,
                          syntax: Syntax.YAML,
                          syntaxTheme: SyntaxTheme.vscodeDark(),
                          fontSize: 12.0,
                          withZoom: true,
                          withLinesCount: true,
                          expanded: false,
                        ),
                        SimpleDialogOption(
                          child: const Text("Okay", textAlign: TextAlign.end),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(
                  flex: 1,
                )
              ],
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
