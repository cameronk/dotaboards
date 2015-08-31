// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@deprecated(
    'The "unittest" package is deprecated. Use the "test" package instead.')
library unittest;

import 'src/configuration.dart';
import 'src/test_case.dart';

export 'package:test/test.dart';

export 'src/configuration.dart';
export 'src/simple_configuration.dart';
export 'src/test_case.dart';

// What follows are stubs for various top-level names supported by unittest
// 0.11.*. These are preserved for the time being for ease of migration, but
// should be removed before this is released as stable.

@deprecated
typedef dynamic TestFunction();

@deprecated
Configuration testConfiguration = new Configuration();

@deprecated
bool formatStacks = true;

@deprecated
bool filterStacks = true;

@deprecated
String groupSep = ' ';

@deprecated
void logMessage(String message) => print(message);

@deprecated
final testCases = [];

@deprecated
const int BREATH_INTERVAL = 200;

@deprecated
TestCase get currentTestCase => null;

@deprecated
const PASS = 'pass';

@deprecated
const FAIL = 'fail';

@deprecated
const ERROR = 'error';

@deprecated
void skip_test(String spec, TestFunction body) {}

@deprecated
void solo_test(String spec, TestFunction body) => test(spec, body);

@deprecated
void skip_group(String description, void body()) {}

@deprecated
void solo_group(String description, void body()) => group(description, body);

@deprecated
void filterTests(testFilter) {}

@deprecated
void runTests() {}

@deprecated
void ensureInitialized() {}

@deprecated
void setSoloTest(int id) {}

@deprecated
void enableTest(int id) {}

@deprecated
void disableTest(int id) {}

@deprecated
withTestEnvironment(callback()) => callback();
