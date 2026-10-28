import 'package:hotelyn_server/hotelyn_server.dart';

class FakeSiteContentClient implements SiteContentClient {
  Map<String, dynamic>? content;
  String? administratorId = 'admin-1';
  Exception? failure;

  @override
  Future<Map<String, dynamic>?> readContent() async {
    if (failure != null) throw failure!;
    return content;
  }

  @override
  Future<void> saveContent(Map<String, dynamic> value) async {
    if (failure != null) throw failure!;
    content = value;
  }

  @override
  Future<bool> isAdministrator(String userId) async {
    if (failure != null) throw failure!;
    return userId == administratorId;
  }
}
