import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hotelyn/core/config/app_config.dart';
import 'package:hotelyn/core/services/clarity_bootstrap.dart'
    as clarity_bootstrap;
import 'package:hotelyn_firebase/hotelyn_firebase.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  bool initializeFirebase = true,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (initializeFirebase) {
    await TrenarFirebase.initialize();
  }
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  if (!kReleaseMode) {
    log('API endpoint: ${AppConfig.apiBaseUrl}');
  }

  clarity_bootstrap.run(
    await builder(),
    isRelease: kReleaseMode,
  );
}
