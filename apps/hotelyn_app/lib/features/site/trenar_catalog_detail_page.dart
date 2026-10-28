import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/features/site/site_strings.dart';
import 'package:hotelyn/features/site/trenar_brand.dart';
import 'package:hotelyn/features/site/trenar_catalog_entry.dart';

class TrenarCatalogDetailPage extends StatelessWidget {
  const TrenarCatalogDetailPage({required this.entry, super.key});

  final TrenarCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = SiteStrings.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.68)
        .clamp(340, 620)
        .toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.label(strings)),
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const ValueKey('catalog-detail-cover'),
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    entry.coverAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(
                          color: TrenarBrand.darkSurface,
                          child: Icon(
                            Icons.landscape_outlined,
                            color: TrenarBrand.goldLight,
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
                          Color(0x26000000),
                          Color(0x00000000),
                          Color(0xD9000000),
                        ],
                        stops: [0, 0.42, 1],
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 18,
                    end: 18,
                    bottom: 20,
                    child: Row(
                      children: [
                        TrenarGlassPanel(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TrenarCategoryIcon(
                                  category: entry.category,
                                  size: 32,
                                ),
                                const SizedBox(width: 9),
                                Text(
                                  entry.label(strings),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (entry.item.location != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TrenarGlassPanel(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: TrenarBrand.goldLight,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          entry.item.location!.text(locale),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color: Colors.white,
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
                      ],
                    ),
                  ),
                  PositionedDirectional(
                    start: 20,
                    end: 20,
                    bottom: entry.item.location == null ? 92 : 86,
                    child: TrenarGlassPanel(
                      borderRadius: 16,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 10,
                        ),
                        child: Text(
                          entry.item.title.text(locale),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 38),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.label(strings),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: TrenarBrand.goldDark,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (entry.item.badge != null)
                            _EntryTag(
                              label: entry.item.badge!.text(locale),
                              icon: Icons.verified_outlined,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        entry.item.title.text(locale),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (entry.item.price != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          entry.item.price!.text(locale),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: TrenarBrand.goldDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text(
                        entry.item.description.text(locale),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.65,
                        ),
                      ),
                      if (entry.item.features.isNotEmpty) ...[
                        const SizedBox(height: 26),
                        Text(
                          strings.text('details'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: [
                            for (final feature in entry.item.features)
                              Chip(
                                avatar: const Icon(
                                  Icons.check_circle_outline,
                                  color: TrenarBrand.goldDark,
                                  size: 17,
                                ),
                                label: Text(feature.text(locale)),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // DÜZELTME: Center yerine Align(heightFactor: 1) kullanıldı.
      // Center, bottomNavigationBar'a verilen tüm yüksekliği kaplayıp
      // body'yi yok ediyordu.
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showRequestSheet(context, strings),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(strings.text('bookingFor')),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRequestSheet(BuildContext context, SiteStrings strings) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final size = MediaQuery.sizeOf(context);
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 680,
                maxHeight: size.height * 0.88,
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height < 700 ? 170 : 220,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            entry.coverAsset,
                            key: const ValueKey('catalog-modal-cover'),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const ColoredBox(
                                  color: TrenarBrand.darkSurface,
                                  child: Icon(
                                    Icons.landscape_outlined,
                                    color: TrenarBrand.goldLight,
                                    size: 54,
                                  ),
                                ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x55000000),
                                  Color(0x00000000),
                                  Color(0xE6000000),
                                ],
                                stops: [0, 0.42, 1],
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            top: 14,
                            start: 16,
                            child: TrenarGlassPanel(
                              borderRadius: 22,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TrenarCategoryIcon(
                                      category: entry.category,
                                      size: 30,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.label(strings),
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            top: 12,
                            end: 12,
                            child: IconButton.filledTonal(
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.48,
                                ),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                          PositionedDirectional(
                            start: 18,
                            end: 18,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entry.item.location != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: TrenarBrand.goldLight,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            entry.item.location!.text(locale),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  entry.item.title.text(locale),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        height: 1.08,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    strings.text('details'),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                if (entry.item.badge != null)
                                  _EntryTag(
                                    label: entry.item.badge!.text(locale),
                                    icon: Icons.verified_outlined,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.item.description.text(locale),
                              key: const ValueKey(
                                'catalog-modal-description',
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.55,
                              ),
                            ),
                            if (entry.item.price != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: TrenarBrand.gold.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: TrenarBrand.gold.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.sell_outlined,
                                      color: TrenarBrand.goldDark,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(
                                        entry.item.price!.text(locale),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (entry.item.features.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                strings.text('details'),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final feature in entry.item.features)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            feature.text(locale),
                                            style: theme.textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            unawaited(
                              context.push<void>(
                                '/booking',
                                extra: TrenarBookingArguments(
                                  content: entry.content,
                                  entry: entry,
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(strings.text('continueBooking')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryTag extends StatelessWidget {
  const _EntryTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => TrenarGlassPanel(
    borderRadius: 20,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: TrenarBrand.goldLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}
