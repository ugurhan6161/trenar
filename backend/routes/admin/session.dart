import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `GET /admin/session` verifies the current session and administrator role.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  return adminAction(
    context,
    (_) async => Response.json(
      body: {'role': 'admin'},
      headers: const {HttpHeaders.cacheControlHeader: 'no-store'},
    ),
  );
}
