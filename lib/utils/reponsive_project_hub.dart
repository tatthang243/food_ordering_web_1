import 'package:flutter/material.dart';
import 'package:food_ordering_web_1/utils/device.dart';

class ResponsiveProjectHub extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveProjectHub({
    Key? key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  }) : super(key: key);

// This size work fine on my design, maybe you need some customization depends on your design
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1050 &&
      MediaQuery.of(context).size.width >= 700;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1050;

  static ScreenType getScreenType(BuildContext context) {
    print(
        'size = ${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height}');
    print('devicePixelRatio = ${MediaQuery.of(context).devicePixelRatio}');
    var width = MediaQuery.of(context).size.width;
    if (width >= 1050) {
      print('getScreenType = Desktop');
      return ScreenType.destop;
    } else if (width < 1050 && width >= 700) {
      print('getScreenType = Tablet');
      return ScreenType.tablet;
    } else {
      print('getScreenType = Mobile');
      return ScreenType.mobile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // If our width is more than 1050 then we consider it a desktop
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1050) {
          print('responsive: desktop');
          return desktop;
        }
        // If width it less then 1050 and more then 700 we consider it as tablet
        else if (constraints.maxWidth >= 700) {
          print('responsive: tablet');
          return tablet;
        }
        // Or less then that we called it mobile
        else {
          print('responsive: mobile');
          return mobile;
        }
      },
    );
  }
}
