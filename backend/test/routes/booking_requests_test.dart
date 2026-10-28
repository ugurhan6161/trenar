import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/booking/requests.dart' as route;
import '../helpers/fake_reservation_notifier.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late _MockRequestContext context;
  late _MockRequest request;
  late FakeReservationNotifier notifier;

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    notifier = FakeReservationNotifier();
    when(() => context.request).thenReturn(request);
    when(() => context.read<ReservationNotifier>()).thenReturn(notifier);
    when(() => request.method).thenReturn(HttpMethod.post);
    when(request.body).thenAnswer(
      (_) async => jsonEncode({
        'name': 'Ada Yılmaz',
        'phone': '+90 532 789 6161',
        'email': 'ada@example.com',
        'service': 'VIP transfer',
        'destination': 'Trabzon',
        'travel_date': '2026-11-12',
        'guests': 2,
        'booking_options': ['Travel insurance', 'Airport greeting'],
        'notes': 'Airport pickup',
      }),
    );
  });

  test('delivers a validated guest request without requiring login', () async {
    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.accepted);
    expect(notifier.request?.name, 'Ada Yılmaz');
    expect(notifier.request?.guests, 2);
    expect(notifier.request?.email, 'ada@example.com');
    expect(notifier.request?.bookingOptions, [
      'Travel insurance',
      'Airport greeting',
    ]);
  });

  test('rejects invalid request data without calling Telegram', () async {
    when(request.body)
        .thenAnswer((_) async => jsonEncode({'name': '', 'guests': 100}));

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.badRequest);
    expect(notifier.request, isNull);
  });

  test(
    'reports Telegram delivery failures instead of claiming success',
    () async {
      notifier.failure = const TelegramDeliveryException();

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.badGateway);
    },
  );

  test('rejects methods other than POST', () async {
    when(() => request.method).thenReturn(HttpMethod.get);

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });
}
