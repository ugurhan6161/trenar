import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

void main() {
  group('TrenarSiteContent', () {
    test('default content round-trips through JSON', () {
      const content = TrenarSiteContent.defaultContent;

      final decoded = TrenarSiteContent.fromJson(content.toJson());

      expect(decoded.phone, content.phone);
      expect(decoded.services, hasLength(content.services.length));
      expect(decoded.customCategories, isEmpty);
      expect(decoded.bookingOptions, hasLength(content.bookingOptions.length));
      expect(
        decoded.bookingOptions.first.text('en'),
        'VIP airport greeting with a name board',
      );
      expect(
        decoded.destinations.first.title.text('en'),
        'Trabzon & Black Sea',
      );
    });

    test('custom categories and catalog image URLs round-trip', () {
      final json =
          Map<String, dynamic>.of(
              TrenarSiteContent.defaultContent.toJson(),
            )
            ..['custom_categories'] = [
              {
                'id': 'airport-transfers',
                'title': {
                  'tr': 'Havalimanı transferleri',
                  'en': 'Airport transfers',
                },
                'image_url': 'https://example.com/category.jpg',
                'items': [
                  {
                    'title': {'tr': 'VIP transfer', 'en': 'VIP transfer'},
                    'description': {
                      'tr': 'Özel ulaşım',
                      'en': 'Private transport',
                    },
                    'price': {'tr': '2.500 TL', 'en': '€75'},
                    'image_url': 'https://example.com/transfer.jpg',
                  },
                ],
              },
            ];

      final decoded = TrenarSiteContent.fromJson(json);

      expect(decoded.customCategories, hasLength(1));
      expect(
        decoded.customCategories.single.title.text('en'),
        'Airport transfers',
      );
      expect(
        decoded.customCategories.single.imageUrl,
        'https://example.com/category.jpg',
      );
      expect(
        decoded.customCategories.single.items.single.imageUrl,
        'https://example.com/transfer.jpg',
      );
      expect(
        decoded.customCategories.single.items.single.price?.text('tr'),
        '2.500 TL',
      );
    });

    test('site text falls back to English when a translation is missing', () {
      const text = SiteText({'en': 'Luxury transport', 'tr': 'VIP ulaşım'});

      expect(text.text('ar'), 'Luxury transport');
    });

    test('rejects invalid required contact and catalog fields', () {
      expect(
        () => TrenarSiteContent.fromJson({'phone': ''}),
        throwsFormatException,
      );
      expect(
        () => SiteContentItem.fromJson({
          'title': {'en': 'Vehicle'},
          'description': {'en': 'Luxury'},
          'price': 100,
        }),
        throwsFormatException,
      );
    });
  });
}
