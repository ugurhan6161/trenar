import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:test/test.dart';

void main() {
  group('TrenarSiteContent', () {
    test('default content round-trips through JSON', () {
      const content = TrenarSiteContent.defaultContent;

      final decoded = TrenarSiteContent.fromJson(content.toJson());

      expect(decoded.phone, content.phone);
      expect(decoded.services, hasLength(content.services.length));
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
