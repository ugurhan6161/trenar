import 'package:flutter/material.dart';
import 'package:hotelyn/features/site/trenar_brand.dart';

class TrenarHomeLoadingSkeleton extends StatefulWidget {
  const TrenarHomeLoadingSkeleton({super.key});

  @override
  State<TrenarHomeLoadingSkeleton> createState() =>
      _TrenarHomeLoadingSkeletonState();
}

class _TrenarHomeLoadingSkeletonState extends State<TrenarHomeLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? TrenarBrand.darkSurface : const Color(0xFFEAE6DE);
    final highlight = isDark
        ? const Color(0xFF383631)
        : const Color(0xFFF5F2EC);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final color = Color.lerp(base, highlight, _pulse.value)!;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SkeletonBlock(
                    color: color,
                    height: 34,
                    width: 260,
                    radius: 10,
                  ),
                  const SizedBox(height: 12),
                  _SkeletonBlock(
                    color: color,
                    height: 18,
                    width: 360,
                    radius: 8,
                  ),
                  const SizedBox(height: 24),
                  _SkeletonBlock(
                    color: color,
                    height: MediaQuery.sizeOf(context).width < 700 ? 310 : 440,
                    radius: 28,
                  ),
                  const SizedBox(height: 28),
                  _SkeletonBlock(
                    color: color,
                    height: 26,
                    width: 210,
                    radius: 8,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      5,
                      (_) => _SkeletonBlock(
                        color: color,
                        height: 42,
                        width: 112,
                        radius: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _SkeletonBlock(
                    color: color,
                    height: 26,
                    width: 180,
                    radius: 8,
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final count = constraints.maxWidth >= 820 ? 4 : 2;
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: List.generate(
                          count,
                          (_) => SizedBox(
                            width: (constraints.maxWidth - (count - 1) * 14) /
                                count,
                            child: _SkeletonBlock(
                              color: color,
                              height: 176,
                              radius: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.color,
    required this.height,
    this.width,
    required this.radius,
  });

  final Color color;
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
