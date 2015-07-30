// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test.frontend.future_matchers;

import 'dart:async';

import 'package:matcher/matcher.dart' hide throws, throwsA, expect, fail;

import '../backend/invoker.dart';
import '../utils.dart';
import 'expect.dart';

/// Matches a [Future] that completes successfully with a value.
///
/// Note that this creates an asynchronous expectation. The call to `expect()`
/// that includes this will return immediately and execution will continue.
/// Later, when the future completes, the actual expectation will run.
///
/// To test that a Future completes with an exception, you can use [throws] and
/// [throwsA].
final Matcher completes = const _Completes(null, '');

/// Matches a [Future] that completes succesfully with a value that matches
/// [matcher].
///
/// Note that this creates an asynchronous expectation. The call to
/// `expect()` that includes this will return immediately and execution will
/// continue. Later, when the future completes, the actual expectation will run.
///
/// To test that a Future completes with an exception, you can use [throws] and
/// [throwsA].
///
/// [description] is an optional tag that can be used to identify the completion
/// matcher in error messages.
Matcher completion(matcher, [String description = '']) =>
    new _Completes(wrapMatcher(matcher), description);

class _Completes extends Matcher {
  final Matcher _matcher;
  final String _id;

  const _Completes(this._matcher, this._id);

  bool matches(item, Map matchState) {
    if (item is! Future) return false;
    Invoker.current.addOutstandingCallback();

    item.then((value) {
      if (_matcher != null) expect(value, _matcher);
      Invoker.current.removeOutstandingCallback();
    }, onError: (error, trace) {
      if (error is TestFailure) {
        Invoker.current.handleError(error, trace);
        return;
      }

      var id = _id == '' ? '' : '${_id} ';
      var reason = 'Expected future ${id}to complete successfully, '
          'but it failed with ${error}';
      if (trace != null) {
        var stackTrace = terseChain(trace).toString();
        stackTrace = '  ${stackTrace.replaceAll('\n', '\n  ')}';
        reason = '$reason\nStack trace:\n$stackTrace';
      }
      fail(reason);
    });

    return true;
  }

  Description describe(Description description) {
    if (_matcher == null) {
      description.add('completes successfully');
    } else {
      description.add('completes to a value that ').addDescriptionOf(_matcher);
    }
    return description;
  }
}
