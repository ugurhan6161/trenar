import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hotelyn/features/site/trenar_catalog_entry.dart';

abstract final class TrenarBrand {
  static const gold = Color(0xFFC5A15A);
  static const goldLight = Color(0xFFE1C17C);
  static const goldDark = Color(0xFF94713A);
  static const ink = Color(0xFF24211B);
  static const lightBackground = Color(0xFFF8F5ED);
  static const lightSurface = Color(0xFFFFFDF8);
  static const darkBackground = Color(0xFF11110F);
  static const darkSurface = Color(0xFF1D1B16);
  static const lightBorder = Color(0xFFE9E0CC);
  static const darkBorder = Color(0xFF3B3529);

  static ColorScheme colorScheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ColorScheme.fromSeed(
      seedColor: gold,
      brightness: brightness,
      surface: isDark ? darkSurface : lightSurface,
    ).copyWith(
      primary: isDark ? goldLight : goldDark,
      onPrimary: isDark ? ink : Colors.white,
      secondary: isDark ? gold : goldDark,
      onSecondary: isDark ? ink : Colors.white,
      surface: isDark ? darkSurface : lightSurface,
      onSurface: isDark ? const Color(0xFFF5F0E4) : ink,
      outline: isDark ? darkBorder : lightBorder,
      outlineVariant: isDark ? darkBorder : lightBorder,
    );
  }
}

class TrenarLogo extends StatelessWidget {
  const TrenarLogo({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark
          ? 'assets/images/brand/trenar_horizontal_gold.png'
          : 'assets/images/brand/trenar_stacked_dark.png',
      height: height,
      width: isDark ? height * 3.2 : height * 1.28,
      fit: BoxFit.contain,
      semanticLabel: 'TRENAR',
    );
  }
}

class TrenarCategoryIcon extends StatelessWidget {
  const TrenarCategoryIcon({
    required this.category,
    this.size = 46,
    super.key,
  });

  final TrenarCatalogCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: TrenarBrand.gold.withValues(alpha: isDark ? 0.18 : 0.13),
        borderRadius: BorderRadius.circular(size * 0.34),
        border: Border.all(
          color: TrenarBrand.gold.withValues(alpha: isDark ? 0.48 : 0.4),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            _categoryIcon(category),
            size: size * 0.47,
            color: isDark ? TrenarBrand.goldLight : TrenarBrand.goldDark,
          ),
          Positioned(
            right: size * 0.14,
            bottom: size * 0.14,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: const BoxDecoration(
                color: TrenarBrand.gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrenarGlassPanel extends StatelessWidget {
  const TrenarGlassPanel({
    required this.child,
    this.borderRadius = 18,
    super.key,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    ),
  );
}

IconData _categoryIcon(TrenarCatalogCategory category) => switch (category) {
  TrenarCatalogCategory.services => Icons.room_service_outlined,
  TrenarCatalogCategory.packages => Icons.luggage_outlined,
  TrenarCatalogCategory.fleet => Icons.directions_car_filled_outlined,
  TrenarCatalogCategory.properties => Icons.apartment_outlined,
  TrenarCatalogCategory.destinations => Icons.explore_outlined,
};
