import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hotelyn/features/site/site_strings.dart';
import 'package:hotelyn/features/site/trenar_brand.dart';
import 'package:hotelyn/features/site/trenar_catalog_entry.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart';

class TrenarCategoryPage extends StatelessWidget {
  const TrenarCategoryPage({
    required this.arguments,
    super.key,
  });

  final TrenarCategoryArguments arguments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = SiteStrings.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final category = arguments.category;
    final summary = '${_items.length}  ·  ${strings.text('curatedOffers')}';
    final entries = [
      for (var index = 0; index < _items.length; index++)
        TrenarCatalogEntry(
          content: arguments.content,
          category: category,
          index: index,
          item: _items[index],
        ),
    ];
    final heroAsset = entries.isEmpty
        ? 'assets/images/brand/trenar_mark_gold.png'
        : entries.first.coverAsset;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 254,
            backgroundColor: theme.scaffoldBackgroundColor,
            title: Text(categoryTitle(category, strings)),
            actions: [
              IconButton(
                tooltip: strings.text('request'),
                onPressed: () => context.push(
                  '/booking',
                  extra: TrenarBookingArguments(content: arguments.content),
                ),
                icon: const Icon(Icons.calendar_month_outlined),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    heroAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: TrenarBrand.darkSurface),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TrenarCategoryIcon(category: category, size: 52),
                        const SizedBox(width: 13),
                        Expanded(
                          child: TrenarGlassPanel(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    categoryTitle(category, strings),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    summary,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
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
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              34,
            ),
            sliver: entries.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyCategory(
                      title: categoryTitle(category, strings),
                      message: strings.text('emptyCategory'),
                    ),
                  )
                : SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.crossAxisExtent < 620
                          ? 1
                          : constraints.crossAxisExtent < 980
                          ? 2
                          : 3;
                      return SliverGrid.builder(
                        itemCount: entries.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: 274,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) => _CategoryCard(
                          entry: entries[index],
                          locale: locale,
                          strings: strings,
                          index: index,
                          onTap: () => context.push(
                            '/catalog/${category.name}/${entries[index].index}',
                            extra: entries[index],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<SiteContentItem> get _items => switch (arguments.category) {
    TrenarCatalogCategory.services => arguments.content.services,
    TrenarCatalogCategory.packages => arguments.content.packages,
    TrenarCatalogCategory.fleet => arguments.content.fleet,
    TrenarCatalogCategory.properties => arguments.content.properties,
    TrenarCatalogCategory.destinations => arguments.content.destinations,
  };
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.entry,
    required this.locale,
    required this.strings,
    required this.index,
    required this.onTap,
  });

  final TrenarCatalogEntry entry;
  final String locale;
  final SiteStrings strings;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entry.item;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index % 5) * 55),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - value)),
          child: child,
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                entry.coverAsset,
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
                top: 13,
                left: 13,
                child: TrenarGlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TrenarCategoryIcon(category: entry.category, size: 25),
                        const SizedBox(width: 7),
                        Text(
                          entry.label(strings),
                          style: theme.textTheme.labelMedium?.copyWith(
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
                left: 14,
                right: 14,
                bottom: 14,
                child: TrenarGlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 11),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title.text(locale),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.price?.text(locale) ??
                                    item.location?.text(locale) ??
                                    item.description.text(locale),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.86),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: TrenarBrand.goldLight,
                          size: 21,
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

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 38),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

String categoryTitle(TrenarCatalogCategory category, SiteStrings strings) =>
    switch (category) {
      TrenarCatalogCategory.services => strings.text('services'),
      TrenarCatalogCategory.packages => strings.text('packages'),
      TrenarCatalogCategory.fleet => strings.text('fleet'),
      TrenarCatalogCategory.properties => strings.text('properties'),
      TrenarCatalogCategory.destinations => strings.text('destinations'),
    };
