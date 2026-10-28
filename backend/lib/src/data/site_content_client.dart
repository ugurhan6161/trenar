import 'package:supabase/supabase.dart';

/// Persistence and authorization checks for the public site catalogue.
abstract interface class SiteContentClient {
  Future<Map<String, dynamic>?> readContent();

  Future<void> saveContent(Map<String, dynamic> content);

  Future<bool> isAdministrator(String userId);
}

/// Supabase-backed implementation. The service-role key stays on the server;
/// public reads are exposed only through the read-only site-content route.
class SupabaseSiteContentClient implements SiteContentClient {
  const SupabaseSiteContentClient(
    this._client, {
    this.requestTimeout = const Duration(seconds: 10),
  });

  final SupabaseClient _client;
  final Duration requestTimeout;

  @override
  Future<Map<String, dynamic>?> readContent() async {
    final row = await _client
        .from('site_content')
        .select('content')
        .eq('id', 'main')
        .maybeSingle()
        .timeout(requestTimeout);
    if (row == null) return null;
    final content = row['content'];
    if (content is! Map<String, dynamic>) {
      throw StateError('Stored site content is not a JSON object.');
    }
    return content;
  }

  @override
  Future<void> saveContent(Map<String, dynamic> content) async {
    await _client
        .from('site_content')
        .upsert({'id': 'main', 'content': content})
        .timeout(requestTimeout);
  }

  @override
  Future<bool> isAdministrator(String userId) async {
    final row = await _client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle()
        .timeout(requestTimeout);
    return row != null && row['role'] == 'admin';
  }
}
