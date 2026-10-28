import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelyn/app/router/app_router.dart';
import 'package:hotelyn/core/domain/repository/repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/core/settings/app_settings.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn/features/site/trenar_brand.dart';
import 'package:hotelyn_api_client/hotelyn_api_client.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:provider/provider.dart' show ChangeNotifierProvider;

class HotelynApp extends StatelessWidget {
  const HotelynApp({
    required this.preferenceRepository,
    required this.authRepository,
    required this.clarityService,
    required this.locationRepository,
    required this.hotelRepository,
    this.settings,
    super.key,
  });

  static final _fallbackSettings = AppSettings();

  final IntroRepository preferenceRepository;
  final AuthRepository authRepository;
  final ClarityService clarityService;
  final LocationRepository locationRepository;
  final domain.HotelRepository hotelRepository;
  final AppSettings? settings;

  @override
  Widget build(BuildContext context) {
    final appSettings = settings ?? _fallbackSettings;
    return ProviderScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: preferenceRepository),
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider.value(value: clarityService),
          RepositoryProvider.value(value: locationRepository),
          ChangeNotifierProvider<AppSettings>.value(value: appSettings),
          RepositoryProvider<domain.HotelRepository>.value(
            value: hotelRepository,
          ),
          if (hotelRepository is AppHotelRepository)
            RepositoryProvider<HotelynApiClient>.value(
              value: (hotelRepository as AppHotelRepository).apiClient,
            ),
        ],
        child: BlocProvider(
          create: (_) {
            final cubit = LocationCubit(
              locationRepository: locationRepository,
            );
            unawaited(
              cubit.loadLocation().catchError((Object error, StackTrace stack) {
                log(
                  'Failed to load initial location',
                  error: error,
                  stackTrace: stack,
                  name: 'HotelynApp',
                );
              }),
            );
            return cubit;
          },
          child: AnimatedBuilder(
            animation: appSettings,
            builder: (context, _) => MaterialApp.router(
              routerConfig: AppRouter.router,
              title: 'TRENAR',
              debugShowCheckedModeBanner: false,
              locale: appSettings.locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('tr'),
                Locale('en'),
                Locale('ar'),
              ],
              themeMode: appSettings.themeMode,
              theme: _buildTheme(Brightness.light),
              darkTheme: _buildTheme(Brightness.dark),
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      fontFamily: 'DMSans',
      brightness: brightness,
      colorScheme: TrenarBrand.colorScheme(brightness),
      scaffoldBackgroundColor: isDark
          ? TrenarBrand.darkBackground
          : TrenarBrand.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? TrenarBrand.darkBackground
            : TrenarBrand.lightBackground,
        foregroundColor: isDark ? const Color(0xFFF5F0E4) : TrenarBrand.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? TrenarBrand.darkSurface : TrenarBrand.lightSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
