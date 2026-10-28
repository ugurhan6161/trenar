import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' hide User;
import 'package:hotelyn_firebase/hotelyn_firebase.dart';

enum _AdminSection {
  overview,
  site,
  services,
  fleet,
  properties,
  destinations,
  packages,
  bookingOptions,
}

const _locales = <String, String>{
  'tr': 'Türkçe',
  'en': 'English',
  'ar': 'العربية',
};

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _loginKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  final Map<String, TextEditingController> _profileControllers = {};

  User? _user;
  TrenarSiteContent _content = TrenarSiteContent.defaultContent;
  _AdminSection _section = _AdminSection.overview;
  String? _status;
  bool _statusIsError = false;
  bool _busy = false;
  bool _hasUnsavedChanges = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    for (final controller in _profileControllers.values) {
      controller.dispose();
    }
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
        setState(() {
          _status = 'Bu hesap etkin bir yönetici değil.';
          _statusIsError = true;
        });
        return;
      }

      final content = await TrenarFirebase.loadSiteContent();
      if (!mounted) return;
      _loadProfileControllers(content);
      setState(() {
        _content = content;
        _user = user;
        _hasUnsavedChanges = false;
        _status = null;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _messageForAuth(error);
        _statusIsError = true;
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _messageForFirebase(error);
        _statusIsError = true;
      });
    } on Object catch (error, stackTrace) {
      log(
        'Admin sign-in failed',
        error: error,
        stackTrace: stackTrace,
        name: 'TrenarAdmin',
      );
      if (!mounted) return;
      setState(() {
        _status = 'Giriş yapılamadı. Bağlantınızı kontrol edin.';
        _statusIsError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _loadProfileControllers(TrenarSiteContent content) {
    for (final controller in _profileControllers.values) {
      controller.dispose();
    }
    _profileControllers.clear();
    for (final field in ['brand', 'headline', 'introduction']) {
      final text = switch (field) {
        'brand' => content.brand,
        'headline' => content.headline,
        _ => content.introduction,
      };
      for (final locale in _locales.keys) {
        _profileControllers['$field.$locale'] = TextEditingController(
          text: text.translations[locale] ?? '',
        );
      }
    }
    for (final field in ['phone', 'email', 'address']) {
      final text = switch (field) {
        'phone' => content.phone,
        'email' => content.email,
        _ => content.address,
      };
      _profileControllers[field] = TextEditingController(text: text);
    }
  }

  Future<void> _saveContent() async {
    final validation = _validateContent();
    if (validation != null) {
      setState(() {
        _status = validation;
        _statusIsError = true;
      });
      return;
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await TrenarFirebase.saveSiteContent(_content);
      if (!mounted) return;
      setState(() {
        _hasUnsavedChanges = false;
        _status = 'Değişiklikler siteye kaydedildi.';
        _statusIsError = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _messageForFirebase(error);
        _statusIsError = true;
      });
    } on Object catch (error, stackTrace) {
      log(
        'Admin content save failed',
        error: error,
        stackTrace: stackTrace,
        name: 'TrenarAdmin',
      );
      if (!mounted) return;
      setState(() {
        _status = 'Kaydetme başarısız oldu. Tekrar deneyin.';
        _statusIsError = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateContent() {
    for (final field in ['brand', 'headline', 'introduction']) {
      if (_profileControllers['$field.tr']?.text.trim().isEmpty ?? true) {
        return '${_fieldTitle(field)} için Türkçe metin boş bırakılamaz.';
      }
    }
    for (final field in ['phone', 'email', 'address']) {
      if (_profileControllers[field]?.text.trim().isEmpty ?? true) {
        return '${_fieldTitle(field)} alanı boş bırakılamaz.';
      }
    }
    return null;
  }

  SiteText _profileText(String field) {
    return SiteText({
      for (final locale in _locales.keys)
        if (_profileControllers['$field.$locale']!.text.trim().isNotEmpty)
          locale: _profileControllers['$field.$locale']!.text.trim(),
    });
  }

  void _onProfileTextChanged(String field) {
    final text = _profileText(field);
    setState(() {
      _content = _copyContent(
        brand: field == 'brand' ? text : null,
        headline: field == 'headline' ? text : null,
        introduction: field == 'introduction' ? text : null,
      );
      _markChanged();
    });
  }

  void _onContactChanged(String field, String value) {
    setState(() {
      _content = _copyContent(
        phone: field == 'phone' ? value : null,
        email: field == 'email' ? value : null,
        address: field == 'address' ? value : null,
      );
      _markChanged();
    });
  }

  void _markChanged() {
    _hasUnsavedChanges = true;
    _status = null;
  }

  TrenarSiteContent _copyContent({
    SiteText? brand,
    SiteText? headline,
    SiteText? introduction,
    String? phone,
    String? email,
    String? address,
    List<SiteContentItem>? services,
    List<SiteContentItem>? fleet,
    List<SiteContentItem>? properties,
    List<SiteContentItem>? destinations,
    List<SiteContentItem>? packages,
    List<SiteText>? bookingOptions,
  }) {
    return TrenarSiteContent(
      brand: brand ?? _content.brand,
      headline: headline ?? _content.headline,
      introduction: introduction ?? _content.introduction,
      phone: phone ?? _content.phone,
      email: email ?? _content.email,
      address: address ?? _content.address,
      license: _content.license,
      services: services ?? _content.services,
      fleet: fleet ?? _content.fleet,
      properties: properties ?? _content.properties,
      destinations: destinations ?? _content.destinations,
      packages: packages ?? _content.packages,
      bookingOptions: bookingOptions ?? _content.bookingOptions,
    );
  }

  List<SiteContentItem> _itemsFor(_AdminSection section) {
    return switch (section) {
      _AdminSection.services => _content.services,
      _AdminSection.fleet => _content.fleet,
      _AdminSection.properties => _content.properties,
      _AdminSection.destinations => _content.destinations,
      _AdminSection.packages => _content.packages,
      _ => const [],
    };
  }

  void _updateItems(
    _AdminSection section,
    List<SiteContentItem> items,
  ) {
    setState(() {
      _content = switch (section) {
        _AdminSection.services => _copyContent(services: items),
        _AdminSection.fleet => _copyContent(fleet: items),
        _AdminSection.properties => _copyContent(properties: items),
        _AdminSection.destinations => _copyContent(destinations: items),
        _AdminSection.packages => _copyContent(packages: items),
        _ => _content,
      };
      _markChanged();
    });
  }

  Future<void> _editItem({
    required _AdminSection section,
    SiteContentItem? item,
    int? index,
  }) async {
    final edited = await showDialog<SiteContentItem>(
      context: context,
      builder: (context) => _CatalogItemDialog(item: item),
    );
    if (edited == null || !mounted) return;
    final items = List<SiteContentItem>.of(_itemsFor(section));
    if (index == null) {
      items.add(edited);
    } else {
      items[index] = edited;
    }
    _updateItems(section, items);
  }

  Future<void> _deleteItem(_AdminSection section, int index) async {
    final item = _itemsFor(section)[index];
    final confirmed = await _confirmDelete(
      title: item.title.text('tr'),
      message: 'Bu kayıt sitedeki katalogdan kaldırılacak.',
    );
    if (!confirmed || !mounted) return;
    final items = List<SiteContentItem>.of(_itemsFor(section))..removeAt(index);
    _updateItems(section, items);
  }

  Future<void> _editBookingOption({SiteText? option, int? index}) async {
    final edited = await showDialog<SiteText>(
      context: context,
      builder: (context) => _BookingOptionDialog(option: option),
    );
    if (edited == null || !mounted) return;
    final options = List<SiteText>.of(_content.bookingOptions);
    if (index == null) {
      options.add(edited);
    } else {
      options[index] = edited;
    }
    setState(() {
      _content = _copyContent(bookingOptions: options);
      _markChanged();
    });
  }

  Future<void> _deleteBookingOption(int index) async {
    final option = _content.bookingOptions[index];
    final confirmed = await _confirmDelete(
      title: option.text('tr'),
      message: 'Bu seçenek rezervasyon formundan kaldırılacak.',
    );
    if (!confirmed || !mounted) return;
    final options = List<SiteText>.of(_content.bookingOptions)..removeAt(index);
    setState(() {
      _content = _copyContent(bookingOptions: options);
      _markChanged();
    });
  }

  Future<bool> _confirmDelete({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.delete_outline),
            title: Text('“$title” silinsin mi?'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Vazgeç'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;
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
    _loadProfileControllers(TrenarSiteContent.defaultContent);
    setState(() {
      _user = null;
      _status = null;
      _hasUnsavedChanges = false;
      _section = _AdminSection.overview;
      _searchController.clear();
      _passwordController.clear();
    });
  }

  void _selectSection(_AdminSection section, {bool closeDrawer = false}) {
    setState(() {
      _section = section;
      _searchController.clear();
    });
    if (closeDrawer) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 920;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          drawer: _user != null && compact
              ? Drawer(child: _navigation(closeDrawer: true))
              : null,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: _user != null && compact
                ? Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Menüyü aç',
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.menu),
                    ),
                  )
                : null,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF171613),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.travel_explore,
                    color: Color(0xFFD8B16A),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TRENAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                      ),
                    ),
                    Text(
                      'YÖNETİM PANELİ',
                      style: TextStyle(fontSize: 9, letterSpacing: 1.4),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              if (_user != null) ...[
                if (_hasUnsavedChanges && !compact)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        'Kaydedilmemiş değişiklikler',
                        style: TextStyle(
                          color: Color(0xFF94620B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: FilledButton.icon(
                    onPressed: _busy || !_hasUnsavedChanges
                        ? null
                        : _saveContent,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: Text(compact ? 'Kaydet' : 'Değişiklikleri kaydet'),
                  ),
                ),
                IconButton(
                  tooltip: 'Çıkış yap',
                  onPressed: _busy ? null : _signOut,
                  icon: const Icon(Icons.logout),
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
          body: _user == null
              ? _loginBody()
              : Row(
                  children: [
                    if (!compact) _navigation(),
                    Expanded(child: _dashboardBody()),
                  ],
                ),
        );
      },
    );
  }

  Widget _loginBody() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: _loginPanel(),
        ),
      ),
    );
  }

  Widget _loginPanel() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE7E8EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _loginKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF171613),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Color(0xFFD8B16A),
                  size: 30,
                ),
              ),
              const SizedBox(height: 24),
              Text('Yönetici girişi', style: _titleStyle(26)),
              const SizedBox(height: 8),
              const Text(
                'TRENAR web sitesinin içeriklerini yönetmek için '
                'yetkili hesabınızla giriş yapın.',
                style: TextStyle(color: Color(0xFF737780), height: 1.5),
              ),
              const SizedBox(height: 26),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration(
                  'E-posta adresi',
                  icon: Icons.mail_outline,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'E-posta adresinizi girin.'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                decoration: _inputDecoration(
                  'Parola',
                  icon: Icons.lock_outline,
                ),
                obscureText: true,
                onFieldSubmitted: (_) => _signIn(),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Parolanızı girin.' : null,
              ),
              if (_status != null) ...[
                const SizedBox(height: 14),
                _statusBanner(),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _busy ? null : _signIn,
                  child: _busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Güvenli giriş yap'),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Yetkisiz hesaplar yönetim alanına erişemez.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF898D96)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigation({bool closeDrawer = false}) {
    return Container(
      width: 252,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Text(
              'ÇALIŞMA ALANI',
              style: TextStyle(
                color: Color(0xFF9296A0),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ),
          for (final section in _AdminSection.values)
            _navigationItem(section, closeDrawer: closeDrawer),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F4EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xFFE9D9B8),
                  child: Icon(
                    Icons.verified_user_outlined,
                    size: 18,
                    color: Color(0xFF735A2B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?.email ?? 'Yönetici',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'Yetkili yönetici',
                        style: TextStyle(
                          color: Color(0xFF89816E),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationItem(
    _AdminSection section, {
    required bool closeDrawer,
  }) {
    final selected = section == _section;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: selected,
        selectedTileColor: const Color(0xFFF5F0E6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          _sectionIcon(section),
          size: 20,
          color: selected ? const Color(0xFF8F6826) : const Color(0xFF777C86),
        ),
        title: Text(
          _sectionTitle(section),
          style: TextStyle(
            color: selected ? const Color(0xFF5D4319) : null,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: section == _AdminSection.overview
            ? null
            : _sectionCount(section) == null
            ? null
            : Text(
                '${_sectionCount(section)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? const Color(0xFF8F6826)
                      : const Color(0xFF8A8E97),
                ),
              ),
        onTap: () => _selectSection(section, closeDrawer: closeDrawer),
      ),
    );
  }

  int? _sectionCount(_AdminSection section) {
    if (section == _AdminSection.bookingOptions) {
      return _content.bookingOptions.length;
    }
    if (section == _AdminSection.overview || section == _AdminSection.site) {
      return null;
    }
    return _itemsFor(section).length;
  }

  Widget _dashboardBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width < 600 ? 18 : 34,
        vertical: 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1260),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader(),
              if (_status != null) ...[
                const SizedBox(height: 18),
                _statusBanner(),
              ],
              const SizedBox(height: 24),
              switch (_section) {
                _AdminSection.overview => _overview(),
                _AdminSection.site => _siteSettings(),
                _AdminSection.bookingOptions => _bookingOptions(),
                _ => _catalogSection(),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader() {
    final section = _section;
    final description = switch (section) {
      _AdminSection.overview =>
        'Web sitenizin içeriklerini tek bir yerden yönetin.',
      _AdminSection.site =>
        'Marka, ana sayfa metinleri ve iletişim bilgilerini düzenleyin.',
      _AdminSection.bookingOptions =>
        'Rezervasyon formunda sunulan tercihleri yönetin.',
      _ =>
        '${_sectionTitle(section)} kayıtlarını ekleyin, düzenleyin veya '
            'kaldırın.',
    };
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_sectionTitle(section), style: _titleStyle(27)),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF7C8089),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        if (_isCatalogSection(section))
          FilledButton.icon(
            onPressed: _busy ? null : () => _editItem(section: section),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Yeni kayıt'),
          )
        else if (section == _AdminSection.bookingOptions)
          FilledButton.icon(
            onPressed: _busy ? null : _editBookingOption,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Seçenek ekle'),
          ),
      ],
    );
  }

  Widget _overview() {
    final total =
        _content.services.length +
        _content.fleet.length +
        _content.properties.length +
        _content.destinations.length +
        _content.packages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 560
                ? 2
                : 1;
            const spacing = 14.0;
            final cardWidth =
                (constraints.maxWidth - (columns - 1) * spacing) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _statCard(
                  width: cardWidth,
                  title: 'Toplam katalog kaydı',
                  value: '$total',
                  detail: 'Yayındaki içerikler',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFFEDE7D9),
                ),
                _statCard(
                  width: cardWidth,
                  title: 'Hizmetler',
                  value: '${_content.services.length}',
                  detail: 'Transfer ve VIP hizmetleri',
                  icon: Icons.room_service_outlined,
                  color: const Color(0xFFE5EEF5),
                ),
                _statCard(
                  width: cardWidth,
                  title: 'Destinasyonlar',
                  value: '${_content.destinations.length}',
                  detail: 'Web sitesindeki rotalar',
                  icon: Icons.place_outlined,
                  color: const Color(0xFFE6EFE8),
                ),
                _statCard(
                  width: cardWidth,
                  title: 'Rezervasyon seçenekleri',
                  value: '${_content.bookingOptions.length}',
                  detail: 'Form tercihleri',
                  icon: Icons.fact_check_outlined,
                  color: const Color(0xFFF3E8E5),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        _panel(
          title: 'İçerik bölümleri',
          subtitle: 'Düzenlemek istediğiniz alanı seçin.',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final section in _AdminSection.values.skip(2))
                ActionChip(
                  avatar: Icon(_sectionIcon(section), size: 17),
                  label: Text(
                    '${_sectionTitle(section)} (${_sectionCount(section)})',
                  ),
                  onPressed: () => _selectSection(section),
                ),
              ActionChip(
                avatar: const Icon(Icons.tune_outlined, size: 17),
                label: const Text('Site bilgileri'),
                onPressed: () => _selectSection(_AdminSection.site),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _panel(
          title: 'Site bilgileri',
          subtitle: 'Müşterilerin göreceği iletişim bilgileri',
          child: Wrap(
            spacing: 28,
            runSpacing: 16,
            children: [
              _contactSummary(Icons.call_outlined, _content.phone),
              _contactSummary(Icons.mail_outline, _content.email),
              _contactSummary(Icons.location_on_outlined, _content.address),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _panel(
          title: 'Yayın durumu',
          subtitle: 'Firebase site içeriğinin durumu',
          child: Row(
            children: [
              const Icon(
                Icons.cloud_done_outlined,
                color: Color(0xFF2D8057),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _hasUnsavedChanges
                      ? 'Kaydedilmemiş değişiklikleriniz var.'
                      : 'Paneldeki içerikler yüklendi. Değişiklikleri '
                            'kaydettiğinizde aynı Firebase kaydı güncellenir.',
                  style: const TextStyle(height: 1.5),
                ),
              ),
              TextButton(
                onPressed: () => _selectSection(_AdminSection.site),
                child: const Text('Siteyi düzenle'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required double width,
    required String title,
    required String value,
    required String detail,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE7E8EB)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF777C86),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 19, color: const Color(0xFF554A33)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(value, style: _titleStyle(30)),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  color: Color(0xFF9296A0),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _siteSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel(
          title: 'Marka ve ana sayfa',
          subtitle: 'Metinleri Türkçe, İngilizce ve Arapça olarak yönetin.',
          child: Column(
            children: [
              _translationGroup('Marka adı', 'brand'),
              const SizedBox(height: 18),
              _translationGroup('Ana başlık', 'headline'),
              const SizedBox(height: 18),
              _translationGroup('Tanıtım metni', 'introduction'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _panel(
          title: 'İletişim bilgileri',
          subtitle: 'Web sitesinde müşterilere gösterilen bilgiler.',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 700 ? 2 : 1;
              const gap = 14.0;
              final width =
                  (constraints.maxWidth - (columns - 1) * gap) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: width,
                    child: _contactField(
                      'phone',
                      'Telefon',
                      Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _contactField(
                      'email',
                      'E-posta',
                      Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _contactField(
                      'address',
                      'Adres',
                      Icons.location_on_outlined,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        _panel(
          title: 'Değişiklikleri yayınla',
          subtitle:
              'Kaydedilen bilgiler müşteri sitesinin kullandığı ortak '
              'Firebase içeriğine yazılır.',
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _busy ? null : _saveContent,
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text('Site bilgilerini kaydet'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _translationGroup(String label, String field) {
    final multiline = field != 'brand';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 760 ? 3 : 1;
            const gap = 12.0;
            final width =
                (constraints.maxWidth - (columns - 1) * gap) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: 12,
              children: [
                for (final locale in _locales.entries)
                  SizedBox(
                    width: width,
                    child: TextField(
                      controller: _profileControllers['$field.${locale.key}'],
                      minLines: multiline ? 2 : 1,
                      maxLines: multiline ? 4 : 1,
                      textDirection: locale.key == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      decoration: _inputDecoration(
                        locale.value,
                        alignLabelWithHint: multiline,
                      ),
                      onChanged: (_) => _onProfileTextChanged(field),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _contactField(
    String field,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: _profileControllers[field],
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon: icon),
      onChanged: (value) => _onContactChanged(field, value),
    );
  }

  Widget _catalogSection() {
    final items = _itemsFor(_section);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = <({int index, SiteContentItem item})>[
      for (var index = 0; index < items.length; index++)
        if (query.isEmpty ||
            items[index].title.text('tr').toLowerCase().contains(query) ||
            items[index].description.text('tr').toLowerCase().contains(query))
          (index: index, item: items[index]),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          decoration:
              _inputDecoration(
                'Kayıtlarda ara',
                icon: Icons.search,
              ).copyWith(
                filled: true,
                fillColor: Colors.white,
                constraints: const BoxConstraints(maxWidth: 420),
              ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          _emptyState(
            query.isEmpty
                ? 'Henüz ${_sectionTitle(_section).toLowerCase()} eklenmemiş.'
                : 'Aramanızla eşleşen bir kayıt bulunamadı.',
            icon: _sectionIcon(_section),
            action: query.isEmpty ? () => _editItem(section: _section) : null,
          )
        else
          for (final entry in filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _catalogCard(entry.item, entry.index),
            ),
      ],
    );
  }

  Widget _catalogCard(SiteContentItem item, int index) {
    final badge = item.badge?.text('tr');
    final location = item.location?.text('tr');
    final price = item.price?.text('tr');
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: const BorderSide(color: Color(0xFFE7E8EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _sectionIcon(_section),
                color: const Color(0xFF8F6826),
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        item.title.text('tr'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (badge != null)
                        _smallLabel(badge, const Color(0xFFF5F0E6)),
                      if (price != null)
                        _smallLabel(price, const Color(0xFFEAF2EC)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description.text('tr'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF777C86),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  if (location != null || item.features.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      [
                        ?location,
                        if (item.features.isNotEmpty)
                          '${item.features.length} özellik',
                      ].join(' · '),
                      style: const TextStyle(
                        color: Color(0xFF9296A0),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Düzenle',
              onPressed: _busy
                  ? null
                  : () => _editItem(
                      section: _section,
                      item: item,
                      index: index,
                    ),
              icon: const Icon(Icons.edit_outlined, size: 19),
            ),
            IconButton(
              tooltip: 'Sil',
              onPressed: _busy ? null : () => _deleteItem(_section, index),
              icon: const Icon(Icons.delete_outline, size: 19),
              color: const Color(0xFFB34343),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_content.bookingOptions.isEmpty)
          _emptyState(
            'Rezervasyon formunda gösterilecek seçenek ekleyin.',
            icon: Icons.fact_check_outlined,
            action: _editBookingOption,
          )
        else
          for (var index = 0; index < _content.bookingOptions.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE7E8EB)),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF5F0E6),
                    child: Icon(
                      Icons.checklist_outlined,
                      color: Color(0xFF8F6826),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _content.bookingOptions[index].text('tr'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    _content.bookingOptions[index].translations.entries
                        .map(
                          (entry) =>
                              '${_locales[entry.key] ?? entry.key}: '
                              '${entry.value}',
                        )
                        .join('  ·  '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        tooltip: 'Düzenle',
                        onPressed: () => _editBookingOption(
                          option: _content.bookingOptions[index],
                          index: index,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Sil',
                        onPressed: () => _deleteBookingOption(index),
                        icon: const Icon(Icons.delete_outline),
                        color: const Color(0xFFB34343),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  Widget _panel({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE7E8EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF858A94),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }

  Widget _emptyState(
    String message, {
    required IconData icon,
    VoidCallback? action,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE7E8EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          children: [
            Icon(icon, size: 34, color: const Color(0xFF9A8B6E)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: action,
                icon: const Icon(Icons.add),
                label: const Text('Yeni kayıt ekle'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _smallLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _contactSummary(IconData icon, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 330),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: const Color(0xFF8F6826)),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBanner() {
    final error = _statusIsError;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFF0EF) : const Color(0xFFEAF5ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: error ? const Color(0xFFF0C8C5) : const Color(0xFFC9E5D0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            size: 19,
            color: error ? const Color(0xFFAD3F3F) : const Color(0xFF327A4E),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              _status!,
              style: TextStyle(
                color: error
                    ? const Color(0xFF8D3333)
                    : const Color(0xFF28613E),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    IconData? icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon, size: 19),
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE1E3E7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE1E3E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFAD8849), width: 1.5),
      ),
    );
  }

  TextStyle _titleStyle(double size) => TextStyle(
    color: const Color(0xFF202127),
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  String _fieldTitle(String field) => switch (field) {
    'brand' => 'Marka adı',
    'headline' => 'Ana başlık',
    'introduction' => 'Tanıtım metni',
    'phone' => 'Telefon',
    'email' => 'E-posta',
    _ => 'Adres',
  };

  String _sectionTitle(_AdminSection section) => switch (section) {
    _AdminSection.overview => 'Genel bakış',
    _AdminSection.site => 'Site bilgileri',
    _AdminSection.services => 'Hizmetler',
    _AdminSection.fleet => 'Araç filosu',
    _AdminSection.properties => 'Konaklama',
    _AdminSection.destinations => 'Destinasyonlar',
    _AdminSection.packages => 'Tur paketleri',
    _AdminSection.bookingOptions => 'Rezervasyon seçenekleri',
  };

  IconData _sectionIcon(_AdminSection section) => switch (section) {
    _AdminSection.overview => Icons.space_dashboard_outlined,
    _AdminSection.site => Icons.web_outlined,
    _AdminSection.services => Icons.room_service_outlined,
    _AdminSection.fleet => Icons.directions_car_outlined,
    _AdminSection.properties => Icons.apartment_outlined,
    _AdminSection.destinations => Icons.place_outlined,
    _AdminSection.packages => Icons.luggage_outlined,
    _AdminSection.bookingOptions => Icons.fact_check_outlined,
  };

  bool _isCatalogSection(_AdminSection section) =>
      section == _AdminSection.services ||
      section == _AdminSection.fleet ||
      section == _AdminSection.properties ||
      section == _AdminSection.destinations ||
      section == _AdminSection.packages;
}

class _CatalogItemDialog extends StatefulWidget {
  const _CatalogItemDialog({this.item});

  final SiteContentItem? item;

  @override
  State<_CatalogItemDialog> createState() => _CatalogItemDialogState();
}

class _CatalogItemDialogState extends State<_CatalogItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String _locale = 'tr';

  @override
  void initState() {
    super.initState();
    for (final field in [
      'title',
      'description',
      'location',
      'price',
      'badge',
      'features',
    ]) {
      final text = switch (field) {
        'title' => widget.item?.title,
        'description' => widget.item?.description,
        'location' => widget.item?.location,
        'price' => widget.item?.price,
        'badge' => widget.item?.badge,
        _ => null,
      };
      for (final locale in _locales.keys) {
        final initial = field == 'features'
            ? _featureText(widget.item?.features ?? const [], locale)
            : text?.translations[locale] ?? '';
        _controllers['$field.$locale'] = TextEditingController(text: initial);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _featureText(List<SiteText> features, String locale) {
    return features
        .map((feature) => feature.translations[locale] ?? '')
        .join('\n');
  }

  SiteText? _optionalText(String field) {
    final translations = <String, String>{
      for (final locale in _locales.keys)
        if (_controllers['$field.$locale']!.text.trim().isNotEmpty)
          locale: _controllers['$field.$locale']!.text.trim(),
    };
    return translations.isEmpty ? null : SiteText(translations);
  }

  SiteText _requiredText(String field) =>
      _optionalText(field) ?? const SiteText({});

  List<SiteText> _features() {
    final lines = <String, List<String>>{
      for (final locale in _locales.keys)
        locale: _controllers['features.$locale']!.text
            .split('\n')
            .map((line) => line.trim())
            .toList(),
    };
    final count = lines.values.fold<int>(
      0,
      (maxLines, localeLines) =>
          localeLines.length > maxLines ? localeLines.length : maxLines,
    );
    return [
      for (var index = 0; index < count; index++)
        SiteText({
          for (final locale in _locales.keys)
            if (index < lines[locale]!.length &&
                lines[locale]![index].isNotEmpty)
              locale: lines[locale]![index],
        }),
    ].where((feature) => feature.translations.isNotEmpty).toList();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      SiteContentItem(
        title: _requiredText('title'),
        description: _requiredText('description'),
        location: _optionalText('location'),
        price: _optionalText('price'),
        badge: _optionalText('badge'),
        features: _features(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Yeni katalog kaydı' : 'Kaydı düzenle'),
      content: SizedBox(
        width: 620,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _locale,
                  decoration: const InputDecoration(
                    labelText: 'Düzenleme dili',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final locale in _locales.entries)
                      DropdownMenuItem(
                        value: locale.key,
                        child: Text(locale.value),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _locale = value);
                  },
                ),
                const SizedBox(height: 14),
                _localizedField(
                  'title',
                  'Başlık',
                  required: _locale == 'tr',
                ),
                const SizedBox(height: 12),
                _localizedField(
                  'description',
                  'Açıklama',
                  required: _locale == 'tr',
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                _localizedField('location', 'Konum'),
                const SizedBox(height: 12),
                _localizedField('price', 'Fiyat bilgisi'),
                const SizedBox(height: 12),
                _localizedField('badge', 'Etiket'),
                const SizedBox(height: 12),
                _localizedField(
                  'features',
                  'Özellikler (her satıra bir özellik)',
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Kaydı tamamla'),
        ),
      ],
    );
  }

  Widget _localizedField(
    String field,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: _controllers['$field.$_locale'],
      minLines: maxLines == 1 ? 1 : 2,
      maxLines: maxLines,
      textDirection: _locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
                ? 'Bu alan gerekli.'
                : null
          : null,
    );
  }
}

class _BookingOptionDialog extends StatefulWidget {
  const _BookingOptionDialog({this.option});

  final SiteText? option;

  @override
  State<_BookingOptionDialog> createState() => _BookingOptionDialogState();
}

class _BookingOptionDialogState extends State<_BookingOptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final locale in _locales.keys) {
      _controllers[locale] = TextEditingController(
        text: widget.option?.translations[locale] ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.option == null
            ? 'Rezervasyon seçeneği ekle'
            : 'Seçeneği düzenle',
      ),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final locale in _locales.entries) ...[
                TextFormField(
                  controller: _controllers[locale.key],
                  textDirection: locale.key == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: locale.value,
                    border: const OutlineInputBorder(),
                  ),
                  validator: locale.key == 'tr'
                      ? (value) => value == null || value.trim().isEmpty
                            ? 'Türkçe seçenek adı gerekli.'
                            : null
                      : null,
                ),
                if (locale.key != 'ar') const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              SiteText({
                for (final locale in _locales.keys)
                  if (_controllers[locale]!.text.trim().isNotEmpty)
                    locale: _controllers[locale]!.text.trim(),
              }),
            );
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
