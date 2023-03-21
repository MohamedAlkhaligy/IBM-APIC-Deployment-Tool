import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  final String _text;
  final AlignmentGeometry alignment;
  final TextStyle? textStyle;
  final bool softWrap;

  const ResponsiveText(
    this._text, {
    this.alignment = Alignment.centerLeft,
    this.textStyle,
    this.softWrap = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(
        _text,
        style: textStyle,
        softWrap: softWrap,
        overflow: TextOverflow.ellipsis,
        maxLines: 5,
      ),
    );
  }
}
