import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/widgets.dart';

void run(Widget app, {required bool isRelease}) {
  runApp(
    ClarityWidget(
      app: app,
      clarityConfig: ClarityConfig(
        projectId: 'vaoffuzfn7',
        logLevel: isRelease ? LogLevel.None : LogLevel.Verbose,
      ),
    ),
  );
}
