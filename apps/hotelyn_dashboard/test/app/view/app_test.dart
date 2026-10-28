// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:hotelyn_dashboard/admin/view/admin_page.dart';
import 'package:hotelyn_dashboard/app/app.dart';

void main() {
  group('App', () {
    testWidgets('renders the admin sign-in screen', (tester) async {
      await tester.pumpWidget(App());
      expect(find.byType(AdminPage), findsOneWidget);
      expect(find.text('Yönetici girişi'), findsOneWidget);
    });
  });
}
