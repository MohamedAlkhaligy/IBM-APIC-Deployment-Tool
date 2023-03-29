import 'dart:ui';
import 'package:flutter/material.dart';

class ChoicesPopUp extends StatelessWidget {
  final String _message;
  final List<String> _choices;

  const ChoicesPopUp(this._message, this._choices, {super.key});

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
                      title: SelectableText(_message),
                      children: _choices
                          .asMap()
                          .entries
                          .map<Widget>(
                            (entry) => SimpleDialogOption(
                              child: Text(entry.value),
                              onPressed: () {
                                Navigator.of(context).pop(entry.key);
                              },
                            ),
                          )
                          .toList(),
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
