import 'package:flutter/material.dart';

/// Screen Size Breakpoints for MediVerse Responsive UI
abstract class ResponsiveBreakpoints {
  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;
  static const double maxContentWidth = 1200.0;
}

/// Adaptive Layout Builder Widget
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < ResponsiveBreakpoints.mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ResponsiveBreakpoints.mobileMax &&
      MediaQuery.sizeOf(context).width <= ResponsiveBreakpoints.tabletMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > ResponsiveBreakpoints.tabletMax;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > ResponsiveBreakpoints.tabletMax) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobileMax) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Container that constrains content to a maximum readable width on wide screens.
class ResponsiveContentConstrainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContentConstrainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
