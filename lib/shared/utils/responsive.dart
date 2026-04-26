import 'package:flutter/material.dart';
import 'dart:math' as math;

class Responsive {
  final double width;
  final double height;
  final double diagonal;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final bool isPortrait;
  final bool isLandscape;

  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = math.sqrt(
      math.pow(size.width, 2) + math.pow(size.height, 2),
    );
    final shortestSide = size.shortestSide;
    final isMobile = shortestSide < 600;
    final isTablet = shortestSide >= 600 && shortestSide < 1024;
    final isDesktop = shortestSide >= 1024;
    final isPortrait = size.height >= size.width;

    return Responsive._(
      width: size.width,
      height: size.height,
      diagonal: diagonal,
      isMobile: isMobile,
      isTablet: isTablet,
      isDesktop: isDesktop,
      isPortrait: isPortrait,
      isLandscape: !isPortrait,
    );
  }

  const Responsive._({
    required this.width,
    required this.height,
    required this.diagonal,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isPortrait,
    required this.isLandscape,
  });

  /// Width percentage
  double wp(double percent) => width * percent / 100;

  /// Height percentage
  double hp(double percent) => height * percent / 100;

  /// Diagonal percentage
  double dp(double percent) => diagonal * percent / 100;

  /// Design pixels (reference: iPhone X 375px wide)
  double px(double designPixels) {
    const double referenceWidth = 375;
    return designPixels * (width / referenceWidth);
  }

  double pxToDp(double designPixels) {
    const double referenceDiagonal = 894;
    return (designPixels / referenceDiagonal) * 100;
  }

  double fontSize(double designPixels) {
    const double referenceWidth = 375;
    final scale = width / referenceWidth;
    final clampedScale = scale.clamp(0.8, 1.3);
    return designPixels * clampedScale;
  }

  double radius(double designPixels) {
    const double referenceWidth = 375;
    return designPixels * (width / referenceWidth);
  }

  double spacing(double designPixels) => px(designPixels);

  double iconSize(double designPixels) => px(designPixels);
}

extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive.of(this);
}
