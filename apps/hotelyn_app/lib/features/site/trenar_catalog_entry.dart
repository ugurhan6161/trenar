import 'package:flutter/material.dart';
import 'package:hotelyn/features/site/site_strings.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';

enum TrenarCatalogCategory {
  services,
  packages,
  fleet,
  properties,
  destinations,
  custom,
}

class TrenarCatalogEntry {
  const TrenarCatalogEntry({
    required this.content,
    required this.category,
    required this.index,
    required this.item,
    this.customCategory,
  });

  final TrenarSiteContent content;
  final TrenarCatalogCategory category;
  final int index;
  final SiteContentItem item;
  final SiteCustomCategory? customCategory;

  String label(SiteStrings strings) => customCategory != null
      ? customCategory!.title.text(strings.languageCode)
      : switch (category) {
          TrenarCatalogCategory.services => strings.text('services'),
          TrenarCatalogCategory.packages => strings.text('packages'),
          TrenarCatalogCategory.fleet => strings.text('fleet'),
          TrenarCatalogCategory.properties => strings.text('properties'),
          TrenarCatalogCategory.destinations => strings.text('destinations'),
          TrenarCatalogCategory.custom => strings.text('services'),
        };

  IconData get icon => switch (category) {
    TrenarCatalogCategory.services => Icons.room_service_outlined,
    TrenarCatalogCategory.packages => Icons.card_travel_outlined,
    TrenarCatalogCategory.fleet => Icons.directions_car_filled_outlined,
    TrenarCatalogCategory.properties => Icons.apartment_outlined,
    TrenarCatalogCategory.destinations => Icons.landscape_outlined,
    TrenarCatalogCategory.custom => Icons.category_outlined,
  };

  String get coverAsset {
    final covers = switch (category) {
      TrenarCatalogCategory.services => const [
        'assets/images/intro/ob2.png',
        'assets/images/intro/ob3.png',
        'assets/images/intro/ob1.png',
      ],
      TrenarCatalogCategory.packages => const [
        'assets/images/intro/ob3.png',
        'assets/images/intro/ob2.png',
        'assets/images/intro/ob1.png',
      ],
      TrenarCatalogCategory.fleet => const [
        'assets/images/intro/ob2.png',
        'assets/images/intro/ob1.png',
        'assets/images/intro/ob3.png',
      ],
      TrenarCatalogCategory.properties => const [
        'assets/images/intro/ob1.png',
        'assets/images/intro/ob3.png',
        'assets/images/intro/ob2.png',
      ],
      TrenarCatalogCategory.destinations => const [
        'assets/images/intro/ob3.png',
        'assets/images/intro/ob2.png',
        'assets/images/intro/ob1.png',
      ],
      TrenarCatalogCategory.custom => const [
        'assets/images/intro/ob1.png',
        'assets/images/intro/ob2.png',
        'assets/images/intro/ob3.png',
      ],
    };
    return covers[index % covers.length];
  }

  Widget coverImage({
    required BoxFit fit,
    Key? key,
    Widget? fallback,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    final imageUrl = item.imageUrl;
    final onError =
        errorBuilder ??
        (context, error, stackTrace) =>
            fallback ??
            const ColoredBox(
              color: Color(0xFF1D1B16),
              child: Icon(
                Icons.landscape_outlined,
                color: Color(0xFFE1C17C),
              ),
            );
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        key: key,
        fit: fit,
        errorBuilder: onError,
      );
    }
    return Image.asset(
      coverAsset,
      key: key,
      fit: fit,
      errorBuilder: onError,
    );
  }

  List<SiteContentItem> get items => switch (category) {
    TrenarCatalogCategory.services => content.services,
    TrenarCatalogCategory.packages => content.packages,
    TrenarCatalogCategory.fleet => content.fleet,
    TrenarCatalogCategory.properties => content.properties,
    TrenarCatalogCategory.destinations => content.destinations,
    TrenarCatalogCategory.custom => customCategory?.items ?? const [],
  };

  static TrenarCatalogCategory? categoryFromPath(String? path) {
    for (final category in TrenarCatalogCategory.values) {
      if (category.name == path) return category;
    }
    return null;
  }
}

class TrenarBookingArguments {
  const TrenarBookingArguments({required this.content, this.entry});

  final TrenarSiteContent content;
  final TrenarCatalogEntry? entry;
}

class TrenarCategoryArguments {
  const TrenarCategoryArguments({
    required this.content,
    required this.category,
    this.customCategory,
  });

  final TrenarSiteContent content;
  final TrenarCatalogCategory category;
  final SiteCustomCategory? customCategory;
}
