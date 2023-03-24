import 'dart:ui';
import 'package:flutter/material.dart';

class ErrorPopUp extends StatelessWidget {
  final String _message;
  final List<String>? errors;
  final bool isDilemma;

  const ErrorPopUp(
    this._message, {
    this.errors,
    this.isDilemma = false,
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
                    child: AlertDialog(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      title: const Text('Error'),
                      content: ListTile(
                        title: SelectableText(_message),
                        subtitle: (errors == null)
                            ? null
                            : SizedBox(
                                height: 150,
                                width: double.maxFinite,
                                child: ListView.builder(
                                  itemCount: errors!.length,
                                  itemBuilder: ((context, index) {
                                    return ListTile(
                                      title: SelectableText(errors![index]),
                                    );
                                  }),
                                ),
                              ),
                      ),
                      actions: isDilemma
                          ? [
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                              TextButton(
                                child: const Text('No'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                              ),
                            ]
                          : [
                              TextButton(
                                child: const Text('Okay'),
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
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
