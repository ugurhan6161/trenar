import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/core/services/clarity_api.dart';
import 'package:hotelyn/core/settings/app_settings.dart';
import 'package:hotelyn/features/site/site_strings.dart';
import 'package:hotelyn/features/site/trenar_brand.dart';
import 'package:hotelyn/features/site/trenar_catalog_entry.dart';
import 'package:hotelyn/features/site/trenar_home_loading_skeleton.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';
import 'package:hotelyn_firebase/hotelyn_firebase.dart';
import 'package:intl/intl.dart';

class TrenarHomePage extends StatefulWidget {
  const TrenarHomePage({super.key});

  @override
  State<TrenarHomePage> createState() => _TrenarHomePageState();
}

class _TrenarHomePageState extends State<TrenarHomePage> {
  final GlobalKey _reservationKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  TrenarSiteContent _content = TrenarSiteContent.defaultContent;
  String? _selectedService;
  bool _requestedContent = false;
  bool _contentLoading = true;
  bool _contentUnavailable = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedContent) return;
    _requestedContent = true;
    unawaited(_loadContent());
  }

  Future<void> _loadContent() async {
    try {
      final content = await TrenarFirebase.initialize()
          .then((_) => TrenarFirebase.loadSiteContent())
          .timeout(const Duration(seconds: 12));
      if (!mounted) return;
      setState(() {
        _content = content;
        _contentLoading = false;
        _contentUnavailable = false;
      });
    } on Object catch (error, stackTrace) {
      log(
        'Could not load the managed TRENAR catalogue',
        error: error,
        stackTrace: stackTrace,
        name: 'TrenarHomePage',
      );
      if (!mounted) return;
      setState(() {
        _contentLoading = false;
        _contentUnavailable = true;
      });
    }
  }

  Future<void> _requestBooking(String service) async {
    setState(() => _selectedService = service);
    final targetContext = _reservationKey.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = SiteStrings.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final settings = context.read<AppSettings>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compactNavigation = MediaQuery.sizeOf(context).width < 900;

    return Scaffold(
      backgroundColor: _SitePalette.background(isDark: isDark),
      appBar: AppBar(
        backgroundColor: _SitePalette.background(isDark: isDark),
        foregroundColor: _SitePalette.text(isDark: isDark),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 12,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [TrenarLogo(height: 46)],
        ),
        actions: [
          IconButton(
            tooltip: strings.text('theme'),
            onPressed: () => unawaited(
              _updateSetting(
                () => settings.setThemeMode(
                  settings.themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark,
                ),
                strings,
              ),
            ),
            icon: Icon(
              settings.themeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: strings.text('language'),
            icon: const Icon(Icons.language),
            onSelected: (language) => unawaited(
              _updateSetting(
                () => settings.setLocale(Locale(language)),
                strings,
              ),
            ),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'tr', child: Text('Türkçe')),
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'ar', child: Text('العربية')),
            ],
          ),
          _SiteMenuButton(
            compact: compactNavigation,
            strings: strings,
            onSelected: _handleMenuAction,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _contentLoading
          ? const TrenarHomeLoadingSkeleton()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_contentUnavailable)
                        _ContentWarning(
                          message: strings.text('contentUnavailable'),
                        ),
                      _HeroSection(
                        content: _content,
                        locale: locale,
                        strings: strings,
                        onBook: () => _requestBooking(strings.text('services')),
                      ),
                      const SizedBox(height: 28),
                      _SectionHeading(title: strings.text('exploreCategories')),
                      const SizedBox(height: 14),
                      _CategoryShortcuts(
                        onSelect: (destination) => _openCategoryPage(
                          destination.category,
                          customCategory: destination.customCategory,
                        ),
                        destinations: [
                          _CategoryDestination(
                            label: strings.text('services'),
                            category: TrenarCatalogCategory.services,
                          ),
                          _CategoryDestination(
                            label: strings.text('packages'),
                            category: TrenarCatalogCategory.packages,
                          ),
                          _CategoryDestination(
                            label: strings.text('fleet'),
                            category: TrenarCatalogCategory.fleet,
                          ),
                          _CategoryDestination(
                            label: strings.text('properties'),
                            category: TrenarCatalogCategory.properties,
                          ),
                          _CategoryDestination(
                            label: strings.text('destinations'),
                            category: TrenarCatalogCategory.destinations,
                          ),
                          for (final category in _content.customCategories)
                            _CategoryDestination(
                              label: category.title.text(locale),
                              category: TrenarCatalogCategory.custom,
                              customCategory: category,
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _CatalogSection(
                        title: strings.text('services'),
                        category: TrenarCatalogCategory.services,
                        content: _content,
                        items: _content.services,
                        locale: locale,
                        onOpenDetails: _openCatalogEntry,
                        strings: strings,
                        onViewAll: () =>
                            _openCategoryPage(TrenarCatalogCategory.services),
                      ),
                      const SizedBox(height: 28),
                      _CatalogSection(
                        title: strings.text('packages'),
                        category: TrenarCatalogCategory.packages,
                        content: _content,
                        items: _content.packages,
                        locale: locale,
                        onOpenDetails: _openCatalogEntry,
                        strings: strings,
                        onViewAll: () =>
                            _openCategoryPage(TrenarCatalogCategory.packages),
                      ),
                      const SizedBox(height: 28),
                      _CatalogSection(
                        title: strings.text('fleet'),
                        category: TrenarCatalogCategory.fleet,
                        content: _content,
                        items: _content.fleet,
                        locale: locale,
                        onOpenDetails: _openCatalogEntry,
                        strings: strings,
                        onViewAll: () =>
                            _openCategoryPage(TrenarCatalogCategory.fleet),
                      ),
                      const SizedBox(height: 28),
                      _CatalogSection(
                        title: strings.text('properties'),
                        category: TrenarCatalogCategory.properties,
                        content: _content,
                        items: _content.properties,
                        locale: locale,
                        onOpenDetails: _openCatalogEntry,
                        strings: strings,
                        onViewAll: () =>
                            _openCategoryPage(TrenarCatalogCategory.properties),
                      ),
                      const SizedBox(height: 28),
                      _CatalogSection(
                        title: strings.text('destinations'),
                        category: TrenarCatalogCategory.destinations,
                        content: _content,
                        items: _content.destinations,
                        locale: locale,
                        onOpenDetails: _openCatalogEntry,
                        strings: strings,
                        onViewAll: () => _openCategoryPage(
                          TrenarCatalogCategory.destinations,
                        ),
                      ),
                      for (final category in _content.customCategories) ...[
                        const SizedBox(height: 28),
                        _CatalogSection(
                          title: category.title.text(locale),
                          category: TrenarCatalogCategory.custom,
                          customCategory: category,
                          content: _content,
                          items: category.items,
                          locale: locale,
                          onOpenDetails: _openCatalogEntry,
                          strings: strings,
                          onViewAll: () => _openCategoryPage(
                            TrenarCatalogCategory.custom,
                            customCategory: category,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ClarityMask(
                        child: Container(
                          key: _reservationKey,
                          child: TrenarBookingForm(
                            content: _content,
                            initialService: _selectedService,
                            locale: locale,
                            strings: strings,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _ContactFooter(
                        key: _contactKey,
                        content: _content,
                        strings: strings,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final targetContext = key.currentContext;
    if (targetContext == null) return;
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.06,
    );
  }

  void _openCatalogEntry(TrenarCatalogEntry entry) {
    unawaited(
      context.push<void>(
        '/catalog/${entry.category.name}/${entry.index}',
        extra: entry,
      ),
    );
  }

  void _openCategoryPage(
    TrenarCatalogCategory category, {
    SiteCustomCategory? customCategory,
  }) {
    unawaited(
      context.push<void>(
        '/catalog/${category.name}',
        extra: TrenarCategoryArguments(
          content: _content,
          category: category,
          customCategory: customCategory,
        ),
      ),
    );
  }

  void _handleMenuAction(_SiteMenuAction action) {
    switch (action) {
      case _SiteMenuAction.home:
        context.go('/home');
      case _SiteMenuAction.services:
        _openCategoryPage(TrenarCatalogCategory.services);
      case _SiteMenuAction.packages:
        _openCategoryPage(TrenarCatalogCategory.packages);
      case _SiteMenuAction.fleet:
        _openCategoryPage(TrenarCatalogCategory.fleet);
      case _SiteMenuAction.properties:
        _openCategoryPage(TrenarCatalogCategory.properties);
      case _SiteMenuAction.destinations:
        _openCategoryPage(TrenarCatalogCategory.destinations);
      case _SiteMenuAction.booking:
        unawaited(
          context.push<void>(
            '/booking',
            extra: TrenarBookingArguments(content: _content),
          ),
        );
      case _SiteMenuAction.contact:
        unawaited(_scrollToSection(_contactKey));
    }
  }

  Future<void> _updateSetting(
    Future<void> Function() update,
    SiteStrings strings,
  ) async {
    try {
      await update();
    } on Object catch (error, stackTrace) {
      log(
        'Could not save site preference',
        error: error,
        stackTrace: stackTrace,
        name: 'TrenarHomePage',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.text('preferenceSaveFailed'))),
      );
    }
  }
}

enum _SiteMenuAction {
  home,
  services,
  packages,
  fleet,
  properties,
  destinations,
  booking,
  contact,
}

class _SiteMenuButton extends StatelessWidget {
  const _SiteMenuButton({
    required this.compact,
    required this.strings,
    required this.onSelected,
  });

  final bool compact;
  final SiteStrings strings;
  final ValueChanged<_SiteMenuAction> onSelected;

  static const _options = <(_SiteMenuAction, String, IconData)>[
    (_SiteMenuAction.home, 'home', Icons.home_outlined),
    (_SiteMenuAction.services, 'services', Icons.room_service_outlined),
    (_SiteMenuAction.packages, 'packages', Icons.card_travel_outlined),
    (_SiteMenuAction.fleet, 'fleet', Icons.directions_car_outlined),
    (_SiteMenuAction.properties, 'properties', Icons.apartment_outlined),
    (_SiteMenuAction.destinations, 'destinations', Icons.landscape_outlined),
    (_SiteMenuAction.booking, 'request', Icons.calendar_month_outlined),
    (_SiteMenuAction.contact, 'contactPage', Icons.contact_support_outlined),
  ];

  @override
  Widget build(BuildContext context) => PopupMenuButton<_SiteMenuAction>(
    tooltip: strings.text('openMenu'),
    onSelected: onSelected,
    icon: compact ? const Icon(Icons.menu_rounded) : null,
    child: compact
        ? null
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(strings.text('menu')),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, size: 19),
              ],
            ),
          ),
    itemBuilder: (context) => [
      for (final (action, label, icon) in _options)
        PopupMenuItem(
          value: action,
          child: Row(
            children: [
              _menuActionIcon(action, icon),
              const SizedBox(width: 12),
              Text(strings.text(label)),
            ],
          ),
        ),
    ],
  );
}

Widget _menuActionIcon(_SiteMenuAction action, IconData icon) {
  final category = switch (action) {
    _SiteMenuAction.services => TrenarCatalogCategory.services,
    _SiteMenuAction.packages => TrenarCatalogCategory.packages,
    _SiteMenuAction.fleet => TrenarCatalogCategory.fleet,
    _SiteMenuAction.properties => TrenarCatalogCategory.properties,
    _SiteMenuAction.destinations => TrenarCatalogCategory.destinations,
    _ => null,
  };
  return category == null
      ? Icon(icon, size: 19, color: TrenarBrand.goldDark)
      : TrenarCategoryIcon(category: category, size: 30);
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.content,
    required this.locale,
    required this.strings,
    required this.onBook,
  });

  final TrenarSiteContent content;
  final String locale;
  final SiteStrings strings;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final destination = content.destinations.isEmpty
        ? null
        : content.destinations.first;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: _SitePalette.accentSurface(isDark: isDark),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_outlined,
                      size: 16,
                      color: _SitePalette.accent(isDark: isDark),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        strings.text('experience'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _SitePalette.accent(isDark: isDark),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 17),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Text(
                content.headline.text(locale),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _SitePalette.text(isDark: isDark),
                  fontSize: compact ? 35 : 52,
                  fontWeight: FontWeight.w700,
                  height: 1.12,
                  letterSpacing: compact ? -0.8 : -1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                content.introduction.text(locale),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _SitePalette.mutedText(isDark: isDark),
                  height: 1.65,
                  fontSize: compact ? 15 : 17,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SizedBox(
                width: double.infinity,
                height: compact ? 310 : 440,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/intro/ob3.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, 0.58),
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: Color(0xFF78948A),
                            child: Icon(
                              Icons.landscape_outlined,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x18000000),
                            Color(0x00000000),
                            Color(0xCC102820),
                          ],
                          stops: [0, 0.38, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      top: 18,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                size: 17,
                                color: TrenarBrand.goldDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                strings.text('heroBadge'),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: TrenarBrand.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      right: 18,
                      bottom: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (destination?.location != null) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          destination!.location!.text(locale),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Text(
                                  destination?.title.text(locale) ??
                                      content.brand.text(locale),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        height: 1.15,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: FilledButton(
                              onPressed: onBook,
                              style: FilledButton.styleFrom(
                                backgroundColor: TrenarBrand.gold,
                                foregroundColor: TrenarBrand.ink,
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 23,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                color: _SitePalette.surface(isDark: isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _SitePalette.border(isDark: isDark),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    _TravelCount(
                      count: content.destinations.length,
                      label: strings.text('destinations'),
                    ),
                    const _TravelCountDivider(),
                    _TravelCount(
                      count: content.packages.length,
                      label: strings.text('packages'),
                    ),
                    const _TravelCountDivider(),
                    _TravelCount(
                      count: content.fleet.length,
                      label: strings.text('fleet'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TravelCount extends StatelessWidget {
  const _TravelCount({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 400;
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              color: _SitePalette.accent(isDark: isDark),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: _SitePalette.mutedText(isDark: isDark),
              fontSize: compact ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelCountDivider extends StatelessWidget {
  const _TravelCountDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    color: _SitePalette.border(
      isDark: Theme.of(context).brightness == Brightness.dark,
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: _SitePalette.text(
          isDark: theme.brightness == Brightness.dark,
        ),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CategoryDestination {
  const _CategoryDestination({
    required this.label,
    required this.category,
    this.customCategory,
  });

  final String label;
  final TrenarCatalogCategory category;
  final SiteCustomCategory? customCategory;
}

class _CategoryShortcuts extends StatelessWidget {
  const _CategoryShortcuts({
    required this.destinations,
    required this.onSelect,
  });

  final List<_CategoryDestination> destinations;
  final ValueChanged<_CategoryDestination> onSelect;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final theme = Theme.of(context);
      final columns = constraints.maxWidth >= 820 ? 4 : 2;
      final itemWidth = (constraints.maxWidth - (columns - 1) * 10) / columns;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final destination in destinations)
            SizedBox(
              width: itemWidth,
              height: 66,
              child: Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelect(destination),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        TrenarCategoryIcon(
                          category: destination.category,
                          size: 38,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class _CatalogSection extends StatelessWidget {
  const _CatalogSection({
    required this.title,
    required this.category,
    required this.content,
    required this.items,
    required this.locale,
    required this.onOpenDetails,
    required this.onViewAll,
    required this.strings,
    this.customCategory,
  });

  final String title;
  final TrenarCatalogCategory category;
  final TrenarSiteContent content;
  final List<SiteContentItem> items;
  final String locale;
  final ValueChanged<TrenarCatalogEntry> onOpenDetails;
  final VoidCallback onViewAll;
  final SiteStrings strings;
  final SiteCustomCategory? customCategory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TrenarCategoryIcon(category: category, size: 34),
            const SizedBox(width: 10),
            Expanded(child: _SectionHeading(title: title)),
            TextButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.arrow_forward_rounded, size: 17),
              label: Text(strings.text('viewAll')),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 380
                ? 238.0
                : constraints.maxWidth < 700
                ? 250.0
                : 266.0;
            return SizedBox(
              height: 310,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final entry = TrenarCatalogEntry(
                    content: content,
                    category: category,
                    index: index,
                    item: items[index],
                    customCategory: customCategory,
                  );
                  return SizedBox(
                    width: cardWidth,
                    child: _CatalogCard(
                      entry: entry,
                      locale: locale,
                      strings: strings,
                      index: index,
                      onOpenDetails: () => onOpenDetails(entry),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.entry,
    required this.locale,
    required this.strings,
    required this.index,
    required this.onOpenDetails,
  });

  final TrenarCatalogEntry entry;
  final String locale;
  final SiteStrings strings;
  final int index;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entry.item;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1),
      duration: Duration(milliseconds: 320 + (index % 5) * 55),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Card(
        margin: const EdgeInsets.all(2),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onOpenDetails,
          child: Stack(
            fit: StackFit.expand,
            children: [
              entry.coverImage(
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: TrenarBrand.darkSurface,
                  child: Icon(
                    Icons.landscape_outlined,
                    color: TrenarBrand.goldLight,
                    size: 42,
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xC8000000)],
                    stops: [0.26, 1],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: TrenarGlassPanel(
                  borderRadius: 16,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TrenarCategoryIcon(category: entry.category, size: 25),
                        const SizedBox(width: 7),
                        Text(
                          entry.label(strings),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: TrenarGlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(13, 11, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title.text(locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.price?.text(locale) ??
                                    item.location?.text(locale) ??
                                    item.description.text(locale),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.86),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: TrenarBrand.goldLight,
                              size: 19,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrenarBookingForm extends StatefulWidget {
  const TrenarBookingForm({
    required this.content,
    required this.initialService,
    required this.locale,
    required this.strings,
    this.initialDestination,
    super.key,
  });

  final TrenarSiteContent content;
  final String? initialService;
  final String? initialDestination;
  final String locale;
  final SiteStrings strings;

  @override
  State<TrenarBookingForm> createState() => _BookingRequestFormState();
}

class _BookingRequestFormState extends State<TrenarBookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  late final TextEditingController _dateController;
  late DateTime _travelDate;
  late String? _selectedService;
  late String? _selectedDestination;
  final Set<int> _selectedBookingOptions = {};
  int _guests = 1;
  bool _sending = false;
  bool? _wasSent;

  @override
  void initState() {
    super.initState();
    _travelDate = DateTime.now().add(const Duration(days: 1));
    _dateController = TextEditingController();
    _syncDate();
    _selectedService = widget.initialService;
    _selectedDestination =
        widget.initialDestination ??
        (widget.content.destinations.isEmpty
            ? null
            : widget.content.destinations.first.title.text(widget.locale));
  }

  @override
  void didUpdateWidget(covariant TrenarBookingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialService != widget.initialService) {
      _selectedService = widget.initialService;
    }
    if (oldWidget.initialDestination != widget.initialDestination) {
      _selectedDestination = widget.initialDestination;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  List<String> get _serviceOptions => {
    ...widget.content.services.map((item) => item.title.text(widget.locale)),
    ...widget.content.fleet.map((item) => item.title.text(widget.locale)),
    ...widget.content.properties.map((item) => item.title.text(widget.locale)),
    ...widget.content.packages.map((item) => item.title.text(widget.locale)),
    ...widget.content.destinations.map(
      (item) => item.title.text(widget.locale),
    ),
  }.toList();

  List<String> get _destinationOptions => {
    ...widget.content.destinations.map(
      (item) => item.title.text(widget.locale),
    ),
    'Antalya',
    'Ordu',
    'Bursa',
  }.toList();

  void _syncDate() {
    _dateController.text = DateFormat.yMMMd(widget.locale).format(_travelDate);
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _travelDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _travelDate = selected;
      _wasSent = null;
      _syncDate();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _wasSent = null;
    });
    try {
      await TrenarFirebase.submitBookingRequest(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        service: _selectedService!,
        destination: _selectedDestination!,
        travelDate: DateFormat('yyyy-MM-dd').format(_travelDate),
        guests: _guests,
        bookingOptions: _selectedBookingOptions
            .where((index) => index < widget.content.bookingOptions.length)
            .map(
              (index) =>
                  widget.content.bookingOptions[index].text(widget.locale),
            )
            .toList(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _wasSent = true);
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _notesController.clear();
    } on Object catch (error, stackTrace) {
      log(
        'Booking request could not be delivered',
        error: error,
        stackTrace: stackTrace,
        name: 'TrenarHomePage',
      );
      if (!mounted) return;
      setState(() => _wasSent = false);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = widget.strings;
    final theme = Theme.of(context);
    final serviceOptions = _serviceOptions;
    final destinationOptions = _destinationOptions;
    if ((_selectedService == null ||
            !serviceOptions.contains(_selectedService)) &&
        serviceOptions.isNotEmpty) {
      _selectedService = serviceOptions.first;
    }
    if ((_selectedDestination == null ||
            !destinationOptions.contains(_selectedDestination)) &&
        destinationOptions.isNotEmpty) {
      _selectedDestination = destinationOptions.first;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.text('request'), style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(strings.text('requestIntro')),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 720 ? 2 : 1;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 14) / columns;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      SizedBox(
                        width: width,
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: strings.text('name'),
                            border: const OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? strings.text('invalidName')
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: strings.text('phone'),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value == null || value.trim().length < 7
                              ? strings.text('invalidPhone')
                              : null,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: strings.text('email'),
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(value.trim())
                                ? null
                                : strings.text('invalidEmail');
                          },
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedService,
                          decoration: InputDecoration(
                            labelText: strings.text('service'),
                            border: const OutlineInputBorder(),
                          ),
                          items: serviceOptions
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: serviceOptions.isEmpty
                              ? null
                              : (value) => setState(() {
                                  _selectedService = value;
                                  _wasSent = null;
                                }),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedDestination,
                          decoration: InputDecoration(
                            labelText: strings.text('destination'),
                            border: const OutlineInputBorder(),
                          ),
                          items: destinationOptions
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: destinationOptions.isEmpty
                              ? null
                              : (value) => setState(() {
                                  _selectedDestination = value;
                                  _wasSent = null;
                                }),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: strings.text('date'),
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: _pickDate,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: DropdownButtonFormField<int>(
                          initialValue: _guests,
                          decoration: InputDecoration(
                            labelText: strings.text('guests'),
                            border: const OutlineInputBorder(),
                          ),
                          items: List.generate(
                            12,
                            (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text('${index + 1}'),
                            ),
                          ),
                          onChanged: (value) => setState(() {
                            _guests = value ?? 1;
                          }),
                        ),
                      ),
                      if (widget.content.bookingOptions.isNotEmpty)
                        SizedBox(
                          width: constraints.maxWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  strings.text('bookingOptions'),
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                              ...widget.content.bookingOptions
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: _selectedBookingOptions.contains(
                                        entry.key,
                                      ),
                                      title: Text(
                                        entry.value.text(widget.locale),
                                      ),
                                      onChanged: (selected) => setState(() {
                                        if (selected ?? false) {
                                          _selectedBookingOptions.add(
                                            entry.key,
                                          );
                                        } else {
                                          _selectedBookingOptions.remove(
                                            entry.key,
                                          );
                                        }
                                        _wasSent = null;
                                      }),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            labelText: strings.text('notes'),
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          maxLength: 1000,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    _sending ||
                        _selectedService == null ||
                        _selectedDestination == null
                    ? null
                    : _submit,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(
                  _sending ? strings.text('sending') : strings.text('send'),
                ),
              ),
            ),
            if (_wasSent != null) ...[
              const SizedBox(height: 12),
              Text(
                _wasSent! ? strings.text('sent') : strings.text('sendFailed'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _wasSent!
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactFooter extends StatelessWidget {
  const _ContactFooter({
    required this.content,
    required this.strings,
    super.key,
  });

  final TrenarSiteContent content;
  final SiteStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.text('contact'), style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            SelectableText(content.address),
            const SizedBox(height: 6),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                SelectableText(content.phone),
                SelectableText(content.email),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentWarning extends StatelessWidget {
  const _ContentWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MaterialBanner(
        content: Text(message),
        leading: const Icon(Icons.cloud_off_outlined),
        actions: const [SizedBox.shrink()],
      ),
    );
  }
}

class _SitePalette {
  const _SitePalette._();

  static Color background({required bool isDark}) =>
      isDark ? TrenarBrand.darkBackground : TrenarBrand.lightBackground;

  static Color surface({required bool isDark}) =>
      isDark ? TrenarBrand.darkSurface : TrenarBrand.lightSurface;

  static Color border({required bool isDark}) =>
      isDark ? TrenarBrand.darkBorder : TrenarBrand.lightBorder;

  static Color text({required bool isDark}) =>
      isDark ? const Color(0xFFF5F0E4) : TrenarBrand.ink;

  static Color mutedText({required bool isDark}) =>
      isDark ? const Color(0xFFC9C0AC) : const Color(0xFF716A5C);

  static Color accent({required bool isDark}) =>
      isDark ? TrenarBrand.goldLight : TrenarBrand.goldDark;

  static Color accentSurface({required bool isDark}) =>
      isDark ? const Color(0xFF332B1D) : const Color(0xFFF1E9D7);
}
