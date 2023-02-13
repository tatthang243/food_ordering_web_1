import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:food_ordering_web_1/repo/new_document_repo.dart';
import 'package:food_ordering_web_1/screens/order_screen.dart';
import 'package:food_ordering_web_1/utils/paths.dart';
import 'package:qlevar_router/qlevar_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var session = FlutterSession();
  bool isLogin = false;
  String loginState = "";
  late int table;
  late String restaurantId;
  late String id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSession();
    print("session " + isLogin.toString());
  }

  _getSession() async {
    isLogin = await FlutterSession().get("isLogin");
    setState(() {
      loginState = isLogin.toString();
    });
  }

  _setSession(String _id, int _table, String _restaurantId) async {
    await session.set("isLogin", true);
    await session.set("id", _id);
    await session.set("table", _table);
    await session.set("restaurantId", _restaurantId);
    QR.toName(AppRoutes.menuPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("This is the login page")),
      body: Center(
        child: ElevatedButton(
            child: Text("Press to login"),
            onPressed: () async {
              bool docCreated = false;
              while (!docCreated) {
                id = generateRandomString(20);
                table = 1;
                restaurantId = "Restaurant A";
                docCreated = await NewDocRepository(
                        isLogin: isLogin,
                        table: table,
                        restaurantId: restaurantId,
                        id: id)
                    .createNewDoc();
              }
              _setSession(id, table, restaurantId);
            }),
      ),
    );
  }
}

String generateRandomString(int len) {
  var r = Random.secure();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
