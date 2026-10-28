import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/features/hotel_detail/hotel_detail.dart';
import 'package:hotelyn/features/notifications/notifications.dart';
import 'package:hotelyn/features/site/trenar_booking_page.dart';
import 'package:hotelyn/features/site/trenar_catalog_detail_page.dart';
import 'package:hotelyn/features/site/trenar_catalog_entry.dart';
import 'package:hotelyn/features/site/trenar_category_page.dart';
import 'package:hotelyn/features/site/trenar_home_page.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/intro',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const TrenarHomePage(),
      ),
      GoRoute(
        path: '/catalog/:category',
        redirect: (context, state) {
          final arguments = state.extra;
          final category = TrenarCatalogEntry.categoryFromPath(
            state.pathParameters['category'],
          );
          if (arguments is! TrenarCategoryArguments ||
              category == null ||
              arguments.category != category ||
              (category == TrenarCatalogCategory.custom &&
                  (arguments.customCategory == null ||
                      !arguments.content.customCategories.any(
                        (item) => item.id == arguments.customCategory!.id,
                      )))) {
            return '/home';
          }
          return null;
        },
        pageBuilder: (context, state) => _animatedPage(
          state,
          TrenarCategoryPage(
            arguments: state.extra! as TrenarCategoryArguments,
          ),
        ),
      ),
      GoRoute(
        path: '/catalog/:category/:index',
        redirect: (context, state) {
          final entry = state.extra;
          final category = TrenarCatalogEntry.categoryFromPath(
            state.pathParameters['category'],
          );
          final index = int.tryParse(state.pathParameters['index'] ?? '');
          if (entry is! TrenarCatalogEntry ||
              category == null ||
              entry.category != category ||
              entry.index != index ||
              (category == TrenarCatalogCategory.custom &&
                  (entry.customCategory == null ||
                      !entry.content.customCategories.any(
                        (item) => item.id == entry.customCategory!.id,
                      )))) {
            return '/home';
          }
          return null;
        },
        pageBuilder: (context, state) => _animatedPage(
          state,
          TrenarCatalogDetailPage(
            entry: state.extra! as TrenarCatalogEntry,
          ),
        ),
      ),
      GoRoute(
        path: '/booking',
        redirect: (context, state) =>
            state.extra is TrenarBookingArguments ? null : '/home',
        builder: (context, state) => TrenarBookingPage(
          arguments: state.extra! as TrenarBookingArguments,
        ),
      ),
      GoRoute(
        path: '/login',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/hotel-detail',
        redirect: (context, state) {
          if (state.extra is! domain.Hotel) return '/home';
          return null;
        },
        builder: (context, state) {
          final hotel = state.extra! as domain.Hotel;
          return HotelDetailPage(hotel: hotel);
        },
      ),
      GoRoute(
        path: '/payment',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}

CustomTransitionPage<void> _animatedPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.035),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
