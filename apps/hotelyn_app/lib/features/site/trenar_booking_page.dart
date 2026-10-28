import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/features/site/site_strings.dart';
import 'package:hotelyn/features/site/trenar_brand.dart';
import 'package:hotelyn/features/site/trenar_catalog_entry.dart';
import 'package:hotelyn/features/site/trenar_home_page.dart';

class TrenarBookingPage extends StatelessWidget {
  const TrenarBookingPage({required this.arguments, super.key});

  final TrenarBookingArguments arguments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = SiteStrings.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final entry = arguments.entry;
    final accent = theme.brightness == Brightness.dark
        ? TrenarBrand.goldLight
        : TrenarBrand.goldDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('request')),
        actions: [
          IconButton(
            tooltip: strings.text('home'),
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (entry != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).width < 600
                          ? 185
                          : 260,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          entry.coverImage(
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                ColoredBox(color: accent),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  accent.withValues(alpha: 0.06),
                                  const Color(0xD5141E1A),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 20,
                            child: TrenarGlassPanel(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    TrenarCategoryIcon(
                                      category: entry.category,
                                      size: 42,
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            entry.label(strings),
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.88),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.item.title.text(locale),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ],
                                      ),
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
                  const SizedBox(height: 20),
                ],
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          entry == null
                              ? strings.text('request')
                              : entry.item.title.text(locale),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          strings.text('requestIntro'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TrenarBookingForm(
                          content: arguments.content,
                          initialService: entry?.item.title.text(locale),
                          initialDestination:
                              entry?.category ==
                                  TrenarCatalogCategory.destinations
                              ? entry?.item.title.text(locale)
                              : entry?.item.location?.text(locale),
                          locale: locale,
                          strings: strings,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
