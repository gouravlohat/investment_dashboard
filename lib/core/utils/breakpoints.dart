import 'package:flutter/widgets.dart';

/// Single source of truth for phone/tablet responsive breakpoints.
class Breakpoints {
  Breakpoints._();

  static const double tablet = 720;
  static const double desktop = 1080;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  /// Summary card grid column count.
  static int summaryColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) return 4;
    if (width >= tablet) return 4;
    return 2;
  }
}
