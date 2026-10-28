import 'package:flutter/widgets.dart';
import 'package:hotelyn/core/services/clarity_bootstrap_stub.dart'
    if (dart.library.io) 'package:hotelyn/core/services/clarity_bootstrap_native.dart'
    as implementation;

void run(Widget app, {required bool isRelease}) =>
    implementation.run(app, isRelease: isRelease);
