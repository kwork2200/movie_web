import 'package:flutter/material.dart';
import '../resources/app_colors.dart';

/// -----------------------------------------------------------------------
/// Shared responsive breakpoints for web/tablet/mobile layouts.
/// Drop this file at: lib/core/presentation/utils/responsive_helper.dart
/// (adjust the import paths in the views if you place it elsewhere).
/// -----------------------------------------------------------------------
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

enum ScreenType { mobile, tablet, desktop, wide }

extension ScreenTypeX on ScreenType {
  bool get isMobile => this == ScreenType.mobile;
  bool get isTablet => this == ScreenType.tablet;
  bool get isDesktopOrWide =>
      this == ScreenType.desktop || this == ScreenType.wide;
}

ScreenType screenTypeOf(double width) {
  if (width < AppBreakpoints.mobile) return ScreenType.mobile;
  if (width < AppBreakpoints.tablet) return ScreenType.tablet;
  if (width < AppBreakpoints.desktop) return ScreenType.desktop;
  return ScreenType.wide;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  ScreenType get screenType => screenTypeOf(screenWidth);
  bool get isDesktopOrWide => screenType.isDesktopOrWide;
}

/// Caps content width on large screens and centers it, so text/cards don't
/// stretch edge-to-edge in a browser window.
class ResponsiveContentArea extends StatelessWidget {
  const ResponsiveContentArea({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth = 960,
    this.wideMaxWidth = 1280,
  });

  final Widget child;
  final double? mobileMaxWidth;
  final double? tabletMaxWidth;
  final double desktopMaxWidth;
  final double wideMaxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = screenTypeOf(constraints.maxWidth);
        final maxWidth = switch (type) {
          ScreenType.mobile => mobileMaxWidth ?? constraints.maxWidth,
          ScreenType.tablet => tabletMaxWidth ?? constraints.maxWidth,
          ScreenType.desktop => desktopMaxWidth,
          ScreenType.wide => wideMaxWidth,
        };
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

/// Adds a subtle hover-lift effect to any card when running on web/desktop
/// (harmless no-op look on touch devices since MouseRegion just won't fire).
class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.child,
    this.scale = 1.04,
    this.borderRadius = 12,
  });

  final Widget child;
  final double scale;
  final double borderRadius;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: AppNetflixThemeColor.black.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// A horizontally-scrolling list on mobile, a wrap-grid on tablet/desktop —
/// so wide browser windows show multiple rows of cards instead of forcing
/// a sideways scroll.
class ResponsiveMediaRow extends StatelessWidget {
  const ResponsiveMediaRow({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.rowHeight = 240,
    this.mobileTabletGridColumns,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double rowHeight;

  /// Force a fixed column count on tablet too (defaults to 3 tablet / 5-6 desktop).
  final int? mobileTabletGridColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = screenTypeOf(constraints.maxWidth);

        if (type.isMobile) {
          return SizedBox(
            height: rowHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) =>
                  HoverLift(child: itemBuilder(context, index)),
            ),
          );
        }

        final columns = mobileTabletGridColumns ??
            (type.isTablet ? 3 : (type == ScreenType.desktop ? 5 : 6));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (context, index) =>
                HoverLift(child: itemBuilder(context, index)),
          ),
        );
      },
    );
  }
}
