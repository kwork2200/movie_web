import 'package:flutter/widgets.dart';

class ScreenUtils {
  final BuildContext context;

  ScreenUtils(this.context);

  static ScreenUtils of(BuildContext context) {
    return ScreenUtils(context);
  }

  // Screen dimensions
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  // Screen aspect ratio
  double get aspectRatio => MediaQuery.of(context).size.aspectRatio;

  // Padding
  double get topPadding => MediaQuery.of(context).padding.top;
  double get bottomPadding => MediaQuery.of(context).padding.bottom;
  double get leftPadding => MediaQuery.of(context).padding.left;
  double get rightPadding => MediaQuery.of(context).padding.right;

  // Safe area
  double get safeHeight => height - topPadding - bottomPadding;

  // Responsive scaling methods
  double setWidth(double percentage) => width * (percentage / 100);
  double setHeight(double percentage) => height * (percentage / 100);

  // Font scaling
  double scaleFont(double fontSize) {
    final scaleFactor = width / 375; // Base width for iPhone X
    return fontSize * scaleFactor;
  }

  // Responsive size based on width
  double responsiveSize(double size) {
    return (size * width) / 375;
  }

  // Check device type
  bool get isTablet => width >= 768;
  bool get isMobile => width < 768;
  bool get isDesktop => width >= 1024;

  // Orientation
  bool get isPortrait => MediaQuery.of(context).orientation == Orientation.portrait;
  bool get isLandscape => MediaQuery.of(context).orientation == Orientation.landscape;
}
