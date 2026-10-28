import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../routes/admin/session.dart' as route;
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
    when(() => request.method).thenReturn(HttpMethod.get);
    when(() => context.read<AuthClient>()).thenReturn(authClient);
    when(() => context.read<SiteContentClient>()).thenReturn(siteContentClient);
  });

  test('requires a bearer token', () async {
    when(() => request.headers).thenReturn(<String, String>{});

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.unauthorized);
  });

  test('rejects authenticated non-admin users', () async {
    when(() => request.headers).thenReturn({
      HttpHeaders.authorizationHeader: 'Bearer access-token',
    });
    siteContentClient.administratorId = 'someone-else';

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.forbidden);
  });

  test('accepts verified administrators', () async {
    when(() => request.headers).thenReturn({
      HttpHeaders.authorizationHeader: 'Bearer access-token',
    });

    final response = await route.onRequest(context);

    expect(response.statusCode, HttpStatus.ok);
    expect(await response.body(), contains('"role":"admin"'));
  });
}
