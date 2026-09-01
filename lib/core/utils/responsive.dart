import 'package:flutter/material.dart';

/// Responsive breakpoints matching the approved MRD:
/// Mobile, Tablet, Desktop (Web/macOS).
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

/// Returns the current layout type based on screen width.
enum LayoutType { mobile, tablet, desktop }

LayoutType layoutTypeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width >= AppBreakpoints.desktop) return LayoutType.desktop;
  if (width >= AppBreakpoints.tablet) return LayoutType.tablet;
  return LayoutType.mobile;
}

/// A convenience widget that rebuilds its [builder] whenever the
/// screen size crosses a breakpoint boundary.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    final layout = layoutTypeOf(context);
    return switch (layout) {
      LayoutType.desktop => (desktop ?? tablet ?? mobile)(context),
      LayoutType.tablet => (tablet ?? mobile)(context),
      LayoutType.mobile => mobile(context),
    };
  }
}

/// Responsive padding — tighter on mobile, wider on desktop.
EdgeInsets responsivePadding(BuildContext context) {
  return switch (layoutTypeOf(context)) {
    LayoutType.desktop => const EdgeInsets.symmetric(horizontal: 120, vertical: 24),
    LayoutType.tablet  => const EdgeInsets.symmetric(horizontal: 48,  vertical: 20),
    LayoutType.mobile  => const EdgeInsets.symmetric(horizontal: 20,  vertical: 16),
  };
}

/// Max-width constrained layout for web / desktop views.
class MaxWidthLayout extends StatelessWidget {
  const MaxWidthLayout({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
