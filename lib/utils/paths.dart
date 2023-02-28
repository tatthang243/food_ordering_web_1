import 'package:flutter_session/flutter_session.dart';
import 'package:food_ordering_web_1/screens/cart_screen.dart';
import 'package:food_ordering_web_1/screens/order_screen.dart';
import 'package:qlevar_router/qlevar_router.dart';

import '../screens/admin_screen.dart';
import '../screens/login_screen.dart';

class AppRoutes {
  static String loginPage = 'Login Page';
  static String cartPage = 'Cart Page';
  static String homePage = 'Home Page';
  static String menuPage = 'Menu Page';
  static String adminPage = 'Admin Page';

  final routes = [
    QRoute(
        name: loginPage,
        path: '/login',
        builder: () => LoginScreen(),
        middleware: [LoginMiddleware()]),
    QRoute(
      name: adminPage,
      path: '/admin',
      builder: () => AdminScreen(),
    ),
    QRoute(
        name: menuPage,
        path: '/',
        pageType: QMaterialPage(),
        builder: () => OrderScreen(),
        middleware: [AuthMiddleware()]),
    QRoute(
        name: cartPage,
        path: '/cart',
        pageType: QMaterialPage(),
        builder: () => CartScreen(),
        middleware: [AuthMiddleware()]),
  ];
}

class LoginMiddleware extends QMiddleware {
  var session = FlutterSession();
  late bool isLogin;
  int table = 0;
  late String restaurantId;
  late String id;

  Future<bool> _loadSession() async {
    isLogin = await session.get("isLogin") ?? false;
    table = await session.get("table");
    restaurantId = await session.get("restaurantId");
    id = await session.get("id");
    return isLogin;
  }

  @override
  Future<String?> redirectGuard(String path) async =>
      await _loadSession() ? '' : null;
}

class AuthMiddleware extends QMiddleware {
  var session = FlutterSession();
  late bool isLogin;
  int table = 0;
  late String restaurantId;
  late String id;

  Future<bool> _loadSession() async {
    isLogin = await session.get("isLogin") ?? false;
    table = await session.get("table");
    restaurantId = await session.get("restaurantId");
    id = await session.get("id");
    return isLogin;
  }

  @override
  Future<String?> redirectGuard(String path) async =>
      await _loadSession() ? null : '/login';
}
