import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_server/hotelyn_server.dart';

/// `GET /site/content` is public. `PUT /site/content` is admin-only and
/// expects `{ "content": <TrenarSiteContent JSON> }`.
Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      try {
        final content = await context.read<SiteContentClient>().readContent();
        return Response.json(
          body: {
            'content': content ?? TrenarSiteContent.defaultContent.toJson(),
          },
          headers: const {
            HttpHeaders.cacheControlHeader: 'public, max-age=60',
          },
        );
      } on Object catch (error, stackTrace) {
        stderr.writeln('GET /site/content failed: $error\n$stackTrace');
        return internalError();
      }
    case HttpMethod.put:
      return adminAction(context, (_) async {
        final parsed = await _parseContent(context);
        if (parsed is Response) return parsed;
        final content = parsed as Map<String, dynamic>;
        await context.read<SiteContentClient>().saveContent(content);
        return Response.json(
          body: {'saved': true},
          headers: const {HttpHeaders.cacheControlHeader: 'no-store'},
        );
      });
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Object> _parseContent(RequestContext context) async {
  final body = await context.request.body();
  if (body.length > 100000) {
    return Response.json(
      statusCode: HttpStatus.requestEntityTooLarge,
      body: {'error': 'content_too_large'},
    );
  }

  final dynamic decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'invalid_json'},
    );
  }
  if (decoded is! Map<String, dynamic> ||
      decoded['content'] is! Map<String, dynamic>) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'content_must_be_an_object'},
    );
  }

  final content = decoded['content'] as Map<String, dynamic>;
  try {
    TrenarSiteContent.fromJson(content);
  } on FormatException catch (error) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'invalid_site_content', 'message': error.message},
    );
  }
  return content;
}
