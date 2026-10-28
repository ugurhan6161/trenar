import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:hotelyn_server/hotelyn_server.dart';
import 'package:supabase/supabase.dart' hide HttpMethod;

HotelDataClient? _dataClient;
SiteContentClient? _siteContentClient;

String _supabaseUrl() =>
    Platform.environment['SUPABASE_URL'] ?? 'http://127.0.0.1:54321';

/// Builds the Supabase-backed data client from the environment, once.
///
/// The server talks to Supabase with the service-role key; that key never
/// reaches a Flutter client. `SUPABASE_URL` falls back to the local-stack
/// default, but the service-role key must be provided explicitly (copy it from
/// `supabase status`) — defaulting it would silently hide a misconfiguration,
/// and every query would then fail at request time instead.
HotelDataClient _resolveDataClient() {
  return _dataClient ??= SupabaseHotelDataClient(
    SupabaseClient(_supabaseUrl(), _serviceRoleKey()),
  );
}

String _serviceRoleKey() {
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (serviceRoleKey == null || serviceRoleKey.isEmpty) {
    throw StateError(
      'SUPABASE_SERVICE_ROLE_KEY must be set to a valid service-role key '
      '(see `supabase status`).',
    );
  }
  return serviceRoleKey;
}

SiteContentClient _resolveSiteContentClient() =>
    _siteContentClient ??= SupabaseSiteContentClient(
      SupabaseClient(_supabaseUrl(), _serviceRoleKey()),
    );

/// Builds a fresh Supabase Auth client from the environment for each request.
///
/// A new [GoTrueClient] per request keeps auth state isolated: GoTrue caches
/// the most recent session on the instance, so a single process-wide client
/// could leak one caller's session into a concurrent request. The client is
/// cheap (no connections held), so per-request construction is the default.
///
/// Auth runs with the ANON key (a public, signed-out flow), never the
/// service-role key — the service role would bypass GoTrue's rate limits and
/// user checks. Required explicitly for the same fail-fast reason as above.
///
/// The GoTrue client uses the IMPLICIT flow: this server is stateless and has
/// no async storage, and PKCE would try to persist a code verifier (and crash
/// with a null-check). We only need GoTrue to send/verify codes and return
/// tokens, not to hold session state, so implicit suits the server side.
AuthClient _resolveAuthClient() {
  final anonKey = Platform.environment['SUPABASE_ANON_KEY'];
  if (anonKey == null || anonKey.isEmpty) {
    throw StateError(
      'SUPABASE_ANON_KEY must be set to a valid anon key '
      '(see `supabase status`).',
    );
  }
  return SupabaseAuthClient(
    GoTrueClient(
      url: '${_supabaseUrl()}/auth/v1',
      headers: {'apikey': anonKey, 'Authorization': 'Bearer $anonKey'},
      autoRefreshToken: false,
      flowType: AuthFlowType.implicit,
    ),
  );
}

Handler middleware(Handler handler) {
  final appHandler = handler
      .use(provider<HotelDataClient>((_) => _resolveDataClient()))
      .use(provider<SiteContentClient>((_) => _resolveSiteContentClient()))
      .use(
        provider<ReservationNotifier>(
          (_) => TelegramReservationNotifier(
            botToken: Platform.environment['TELEGRAM_BOT_TOKEN'],
            chatId: Platform.environment['TELEGRAM_CHAT_ID'],
          ),
        ),
      )
      .use(provider<AuthClient>((_) => _resolveAuthClient()));

  return (context) async {
    final origin = context.request.headers['origin'];
    final allowedOrigins = (Platform.environment['WEB_ALLOWED_ORIGINS'] ?? '')
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
    final originAllowed =
        origin != null &&
        (allowedOrigins.isEmpty ||
            allowedOrigins.contains('*') ||
            allowedOrigins.contains(origin));
    final corsHeaders = <String, Object>{
      if (originAllowed)
        'Access-Control-Allow-Origin': allowedOrigins.contains('*')
            ? '*'
            : origin,
      'Access-Control-Allow-Headers': 'Authorization, Content-Type',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, OPTIONS',
      'Access-Control-Max-Age': '600',
      'Vary': 'Origin',
    };

    if (context.request.method == HttpMethod.options) {
      return Response(statusCode: 204, headers: corsHeaders);
    }

    final response = await appHandler(context);
    return response.copyWith(
      headers: {...response.headers, ...corsHeaders},
    );
  };
}
