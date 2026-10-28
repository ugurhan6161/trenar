import 'package:flutter/material.dart';
import 'package:hotelyn/features/site/site_strings.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';

enum TrenarCatalogCategory {
  services,
  packages,
  fleet,
  properties,
  destinations,
}

class TrenarCatalogEntry {
  const TrenarCatalogEntry({
    required this.content,
    required this.category,
    required this.index,
    required this.item,
  });

  final TrenarSiteContent content;
  final TrenarCatalogCategory category;
  final int index;
  final SiteContentItem item;

  String label(SiteStrings strings) => switch (category) {
    TrenarCatalogCategory.services => strings.text('services'),
    TrenarCatalogCategory.packages => strings.text('packages'),
    TrenarCatalogCategory.fleet => strings.text('fleet'),
    TrenarCatalogCategory.properties => strings.text('properties'),
    TrenarCatalogCategory.destinations => strings.text('destinations'),
  };

  IconData get icon => switch (category) {
    TrenarCatalogCategory.services => Icons.room_service_outlined,
    TrenarCatalogCategory.packages => Icons.card_travel_outlined,
    TrenarCatalogCategory.fleet => Icons.directions_car_filled_outlined,
    TrenarCatalogCategory.properties => Icons.apartment_outlined,
    TrenarCatalogCategory.destinations => Icons.landscape_outlined,
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
    };
    return covers[index % covers.length];
  }

  List<SiteContentItem> get items => switch (category) {
    TrenarCatalogCategory.services => content.services,
    TrenarCatalogCategory.packages => content.packages,
    TrenarCatalogCategory.fleet => content.fleet,
    TrenarCatalogCategory.properties => content.properties,
    TrenarCatalogCategory.destinations => content.destinations,
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
  });

  final TrenarSiteContent content;
  final TrenarCatalogCategory category;
}
