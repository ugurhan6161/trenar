import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' hide User;
import 'package:hotelyn_firebase/hotelyn_firebase.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _loginKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _contentController = TextEditingController();
  User? _user;
  String? _status;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_loginKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final credential = await TrenarFirebase.auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = credential.user;
      if (user == null || !await TrenarFirebase.verifyAdminAccess(user.uid)) {
        await TrenarFirebase.auth.signOut();
        if (!mounted) return;
        setState(() => _status = 'Bu hesap etkin bir yönetici değil.');
        return;
      }
      final content = await TrenarFirebase.loadSiteContent();
      if (!mounted) return;
      _contentController.text = const JsonEncoder.withIndent(
        '  ',
      ).convert(content.toJson());
      setState(() {
        _user = user;
        _status = null;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _status = _messageForAuth(error));
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _status = _messageForFirebase(error));
    } on Object catch (error, stackTrace) {
      log(
        'Admin sign-in failed',
        error: error,
        stackTrace: stackTrace,
        name: 'TrenarAdmin',
      );
      if (!mounted) return;
      setState(() => _status = 'Giriş yapılamadı. Bağlantınızı kontrol edin.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveContent() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final decoded = jsonDecode(_contentController.text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('İçerik JSON nesnesi olmalıdır.');
      }
      final content = TrenarSiteContent.fromJson(decoded);
      await TrenarFirebase.saveSiteContent(content);
      if (!mounted) return;
      setState(() => _status = 'Site verileri kaydedildi.');
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() => _status = 'JSON doğrulanamadı: ${error.message}');
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _status = _messageForFirebase(error));
    } on Object catch (error, stackTrace) {
      log(
        'Admin content save failed',
        error: error,
        stackTrace: stackTrace,
        name: 'TrenarAdmin',
      );
      if (!mounted) return;
      setState(() => _status = 'Kaydetme başarısız oldu. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _messageForAuth(FirebaseAuthException error) {
    if (error.code == 'invalid-credential' ||
        error.code == 'user-not-found' ||
        error.code == 'wrong-password') {
      return 'E-posta veya parola hatalı.';
    }
    if (error.code == 'operation-not-allowed') {
      return 'Firebase Console’da E-posta/Şifre girişini etkinleştirin.';
    }
    return 'Giriş yapılamadı. (${error.code})';
  }

  String _messageForFirebase(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'Yetki reddedildi. Admin UID ve Firestore yetkilerini '
          'kontrol edin.';
    }
    return 'Firebase isteği tamamlanamadı. (${error.code})';
  }

  Future<void> _signOut() async {
    await TrenarFirebase.auth.signOut();
    setState(() {
      _user = null;
      _status = null;
      _contentController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TRENAR VIP · Yönetim',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_user != null)
            TextButton.icon(
              onPressed: _busy ? null : _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış'),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _user == null ? _loginPanel(theme) : _editorPanel(theme),
          ),
        ),
      ),
    );
  }

  Widget _loginPanel(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _loginKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 44,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Yönetici girişi',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Site içeriğini düzenlemek için yönetici hesabınızla giriş '
                  'yapın. Müşterilerin rezervasyon talebi göndermek için '
                  'hesap açması gerekmez.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'E-posta adresinizi girin.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Parola',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onFieldSubmitted: (_) => _signIn(),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Parolanızı girin.'
                      : null,
                ),
                if (_status != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _status!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _signIn,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Giriş yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editorPanel(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Site verileri', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text(
          'Aşağıdaki JSON; iletişim bilgilerini, hizmetleri, araç filosunu, '
          'gayrimenkulleri ve rotaları içerir. Metin alanları tr/en/ar dil '
          'anahtarlarıyla düzenlenebilir. Kaydetmeden önce içerik doğrulanır.',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _contentController,
          minLines: 24,
          maxLines: 40,
          keyboardType: TextInputType.multiline,
          autocorrect: false,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
            labelText: 'Düzenlenebilir site kataloğu (JSON)',
          ),
        ),
        if (_status != null) ...[
          const SizedBox(height: 12),
          Text(
            _status!,
            style: TextStyle(
              color: _status == 'Site verileri kaydedildi.'
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _busy ? null : _saveContent,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Değişiklikleri kaydet'),
          ),
        ),
      ],
    );
  }
}
