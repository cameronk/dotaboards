// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test.runner.load_exception;

import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:source_span/source_span.dart';

import '../utils.dart';

class LoadException implements Exception {
  final String path;

  final innerError;

  LoadException(this.path, this.innerError);

  String toString({bool color: false}) {
    var buffer = new StringBuffer();
    if (color) buffer.write('\u001b[31m'); // red
    buffer.write('Failed to load "$path":');
    if (color) buffer.write('\u001b[0m'); // no color

    var innerString = getErrorMessage(innerError);
    if (innerError is IsolateSpawnException) {
      // If this is a parse error, get rid of the noisy preamble.
      innerString = innerString
          .replaceFirst("'${p.toUri(p.absolute(path))}': error: ", "");

      // If this is a file system error, get rid of both the preamble and the
      // useless stack trace.
      innerString = innerString.replaceFirst(
          "Unhandled exception:\n"
          "Uncaught Error: Load Error: ",
          "");
      innerString = innerString.replaceFirst("FileSystemException: ", "");
      innerString = innerString.split("Stack Trace:\n").first.trim();
    } if (innerError is SourceSpanException) {
      innerString = innerError.toString(color: color)
          .replaceFirst(" of $path", "");
    }

    buffer.write(innerString.contains("\n") ? "\n" : " ");
    buffer.write(innerString);
    return buffer.toString();
  }
}
