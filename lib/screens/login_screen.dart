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
    if (QR.params['table'] != null) {
      table = (QR.params['table']!.asInt)!;
    }
    if (QR.params['restaurantId'] != null) {
      restaurantId = QR.params['restaurantId']!.toString();
    }

    // TODO: implement initState
    // print('table ' + table.toString());
    // print('restaurant ' + restaurantId.toString());

    super.initState();
  }

  _setSession(String _id, int _table, String _restaurantId) async {
    await session.set("isLogin", true);
    await session.set("id", _id);
    await session.set("table", _table);
    await session.set("restaurantId", _restaurantId);
    print(await session.get("isLogin"));
    QR.toName(AppRoutes.menuPage);
  }

  Future<String> _createDoc() async {
    if (QR.params['table'] == null || QR.params['restaurantId'] == null) {
      return 'nothing';
    } else {
      bool docCreated = false;
      // table = 1;
      // restaurantId = "Restaurant A";
      String tempId = await NewDocRepository(
              isLogin: isLogin, table: table, restaurantId: restaurantId)
          .getOpenOrderId();
      if (tempId == '') {
        while (!docCreated) {
          id = generateRandomString(20);
          docCreated = await NewDocRepository(
            isLogin: isLogin,
            table: table,
            restaurantId: restaurantId,
          ).createNewDoc(id);
        }
      } else {
        id = tempId;
        docCreated = true;
      }
      print('id: ' + id);
      _setSession(id, table, restaurantId);
      return 'bye';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: _createDoc(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  "Login page",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                backgroundColor: Colors.black,
              ),
              body: Center(child: Text('Scan QR code to login')),
            );
          } else {
            return Center(
                child: Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    )));
          }
        });
  }
}

String generateRandomString(int len) {
  var r = Random.secure();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
