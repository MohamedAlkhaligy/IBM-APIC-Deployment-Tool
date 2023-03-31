import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';

class FileOutput extends LogOutput {
  final File file;
  final bool overrideExisting;
  final Encoding encoding;
  final IOSink _sink;

  FileOutput(
    this.file, {
    this.overrideExisting = false,
    this.encoding = utf8,
  }) : _sink = file.openWrite(
          mode:
              overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
          encoding: encoding,
        );

  @override
  void output(OutputEvent event) {
    _sink.writeAll(event.lines, '\n');
  }
}
