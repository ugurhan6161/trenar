import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/site/content.dart' as route;
import '../helpers/fake_auth_client.dart';
import '../helpers/fake_site_content_client.dart';

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late _MockRequestContext context;
  late _MockRequest request;
  late FakeAuthClient authClient;
  late FakeSiteContentClient siteContentClient;

  setUp(() {
    context = _MockRequestContext();
    request = _MockRequest();
    authClient = FakeAuthClient();
    siteContentClient = FakeSiteContentClient();
    when(() => context.request).thenReturn(request);
    when(() => context.read<AuthClient>()).thenReturn(authClient);
    when(() => context.read<SiteContentClient>()).thenReturn(siteContentClient);
  });

  test(
    'public GET returns the built-in catalogue before the first save',
    () async {
      when(() => request.method).thenReturn(HttpMethod.get);

      final response = await route.onRequest(context);

      expect(response.statusCode, HttpStatus.ok);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(
        TrenarSiteContent.fromJson(body['content'] as Map<String, dynamic>)
            .phone,
        TrenarSiteContent.defaultContent.phone,
      );
    },
  );

  test('PUT requires a verified admin session', () async {
    when(() => request.method).thenReturn(HttpMethod.put);
    when(() => request.headers).thenReturn(<String, String>{});
    when(request.body).thenAnswer(
      (_) async => jsonEncode({
        'content': TrenarSiteContent.defaultContent.toJson(),
      }),
    );

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.unauthorized);
    expect(siteContentClient.content, isNull);
  });

  test('authenticated non-admin cannot edit site content', () async {
    when(() => request.method).thenReturn(HttpMethod.put);
    when(() => request.headers).thenReturn({
      HttpHeaders.authorizationHeader: 'Bearer access-token',
    });
    when(request.body).thenAnswer(
      (_) async => jsonEncode({
        'content': TrenarSiteContent.defaultContent.toJson(),
      }),
    );
    siteContentClient.administratorId = 'different-user';

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.forbidden);
    expect(siteContentClient.content, isNull);
  });

  test('admin can save valid site content', () async {
    when(() => request.method).thenReturn(HttpMethod.put);
    when(() => request.headers).thenReturn({
      HttpHeaders.authorizationHeader: 'Bearer access-token',
    });
    when(request.body).thenAnswer(
      (_) async => jsonEncode({
        'content': TrenarSiteContent.defaultContent.toJson(),
      }),
    );

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.ok);
    expect(siteContentClient.content?['phone'], '+90 532 789 6161');
  });

  test('rejects invalid site content before saving', () async {
    when(() => request.method).thenReturn(HttpMethod.put);
    when(() => request.headers).thenReturn({
      HttpHeaders.authorizationHeader: 'Bearer access-token',
    });
    when(request.body).thenAnswer(
      (_) async => jsonEncode({
        'content': {'phone': 'not enough'},
      }),
    );

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.badRequest);
    expect(siteContentClient.content, isNull);
  });
}
