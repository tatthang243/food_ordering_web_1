import 'dart:ui';
import 'package:food_ordering_web_1/repo/order_repo.dart';
import 'package:food_ordering_web_1/utils/paths.dart';
import 'package:qlevar_router/qlevar_router.dart';
import 'package:quantity_input/quantity_input.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:food_ordering_web_1/utils/food_map.dart';

import 'order_dialog.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  List<Map<String, dynamic>> map = [];
  var session = FlutterSession();
  bool isLogin = false;
  int table = 0;
  late String restaurantId;
  late String id;

  @override
  void initState() {
    // TODO: implement initState
    map = FoodMap().tempMap;
    // _loadSession();
    super.initState();
  }

  Future<String> _loadSession() async {
    isLogin = await session.get("isLogin");
    table = await session.get("table");
    restaurantId = await session.get("restaurantId");
    id = await session.get("id");
    print(restaurantId);
    return ("_loadSession called = " + table.toString());
  }

  @override
  Widget build(context) {
    return FutureBuilder<String>(
        future: _loadSession(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                backgroundColor: Colors.grey[200],
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.black,
                  child: Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    QR.toName(AppRoutes.cartPage);
                  },
                ),
                appBar: AppBar(
                  title: Text(
                    "The Menu",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.black,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                ),
                body: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 30,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        "Table number: " + table.toString(),
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: map.length,
                        itemBuilder: ((context, index) => Card(
                                child: FoodItem(
                              foodItem: map[index],
                              table: table,
                              id: id,
                              restaurantId: restaurantId,
                              isLogin: isLogin,
                            ))),
                      ),
                    ),
                  ],
                ));
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}

class FoodItem extends StatefulWidget {
  const FoodItem(
      {Key? key,
      required this.foodItem,
      required this.isLogin,
      required this.table,
      required this.restaurantId,
      required this.id})
      : super(key: key);

  final Map<String, dynamic> foodItem;
  final bool isLogin;
  final int table;
  final String restaurantId;
  final String id;
  @override
  State<FoodItem> createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => OrderDialog(
                  foodItem: widget.foodItem,
                  id: widget.id,
                  restaurantId: widget.restaurantId,
                  table: widget.table,
                  isLogin: widget.isLogin,
                ));
      },
      child: Container(
        width: double.infinity,
        height: 100,
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.network(widget.foodItem['picture']),
                )),
            const SizedBox(
              width: 15,
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.foodItem['meal'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text('Giá: ' + widget.foodItem['price'].toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.foodItem['description'],
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
