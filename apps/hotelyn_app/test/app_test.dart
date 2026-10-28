import 'dart:ui' show Size;

import 'package:flutter/material.dart' show MaterialApp, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn/app/router/app_router.dart';
import 'package:hotelyn/app/view/app.dart';
import 'package:hotelyn/core/domain/repository/auth_repository.dart';
import 'package:hotelyn/core/domain/repository/intro_repository.dart';
import 'package:hotelyn/core/services/clarity_service.dart';
import 'package:hotelyn/core/settings/app_settings.dart';
import 'package:hotelyn/features/location/location.dart';
import 'package:hotelyn/features/site/trenar_catalog_detail_page.dart';
import 'package:hotelyn/features/site/trenar_catalog_entry.dart';
import 'package:hotelyn/features/site/trenar_category_page.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'helpers/helpers.dart';

void main() {
  group('HotelynApp', () {
    late IntroRepository preferenceRepository;
    late AuthRepository authRepository;
    late ClarityService clarityService;
    late LocationRepository locationRepository;
    late domain.HotelRepository hotelRepository;

    setUp(() {
      preferenceRepository = MockPreferenceRepository();
      authRepository = MockAuthRepository();
      clarityService = MockClarityService();
      locationRepository = MockLocationRepository();
      hotelRepository = MockHotelRepository();

      when(() => preferenceRepository.isIntroPassed())
          .thenAnswer((_) async => false);
      when(() => authRepository.isAuthenticated).thenReturn(false);
      when(() => locationRepository.getLocation())
          .thenAnswer((_) async => UserLocation.defaultFallback);
      when(() => locationRepository.getPermissionStatus())
          .thenAnswer((_) async => LocationPermissionStatus.unknown);
      when(
        () => hotelRepository.recommendedHotels(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          radiusKm: any(named: 'radiusKm'),
        ),
      ).thenAnswer((_) async => <domain.Hotel>[]);
    });

    testWidgets(
      'App launches successfully',
      (tester) async {
        tester.view
          ..physicalSize = const Size(390, 844)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          HotelynApp(
            preferenceRepository: preferenceRepository,
            authRepository: authRepository,
            clarityService: clarityService,
            locationRepository: locationRepository,
            hotelRepository: hotelRepository,
          ),
        );
        expect(find.byType(HotelynApp), findsOneWidget);
        final appContext = tester.element(find.byType(MaterialApp));
        expect(
          tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
          'TRENAR',
        );
        expect(
          Provider.of<AppSettings>(appContext, listen: false),
          isA<AppSettings>(),
        );

        AppRouter.router.go(
          '/catalog/services',
          extra: const TrenarCategoryArguments(
            content: domain.TrenarSiteContent.defaultContent,
            category: TrenarCatalogCategory.services,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(TrenarCategoryPage), findsOneWidget);

        await tester.tapAt(const Offset(190, 405));
        await tester.pumpAndSettle();
        expect(find.byType(TrenarCatalogDetailPage), findsOneWidget);
        final coverFinder = find.byKey(const ValueKey('catalog-detail-cover'));
        expect(
          tester.getSize(coverFinder).height,
          greaterThan(300),
        );
        expect(tester.getTopLeft(coverFinder).dy, lessThan(200));
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Bu hizmet için talep'));
        await tester.pumpAndSettle();
        expect(find.text('Rezervasyona devam et'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('catalog-modal-cover')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('catalog-modal-description')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
