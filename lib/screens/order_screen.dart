import 'dart:ui';
import 'package:food_ordering_web_1/repo/order_repo.dart';
import 'package:food_ordering_web_1/utils/paths.dart';
import 'package:provider/provider.dart';
import 'package:qlevar_router/qlevar_router.dart';
import 'package:quantity_input/quantity_input.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:food_ordering_web_1/utils/food_map.dart';

import '../model/order_model.dart';
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
            return StreamProvider<OrderModel>.value(
                value: OrderRepository(
                        isLogin: isLogin,
                        table: table,
                        restaurantId: restaurantId,
                        id: id)
                    .getStreamFromFirebase(),
                initialData: OrderModel(true, [], id),
                child: Builder(builder: (context) {
                  var order = Provider.of<OrderModel>(context);
                  List allTrays = [];
                  String stringTray = '';
                  bool cleanUpEnable = false;
                  if (order.items
                      .any((element) => element.status == "Eating")) {
                    cleanUpEnable = true;
                  }
                  for (var item in order.items
                      .where((element) => element.status == "Arrived")) {
                    // for (var tray in item.tray ?? []) {
                    allTrays.add(item.tray);
                    // }
                  }
                  for (var element in allTrays) {
                    stringTray += element.toString() + ' ';
                  }
                  return Scaffold(
                      backgroundColor: Colors.grey[200],
                      floatingActionButton:
                          Wrap(direction: Axis.vertical, children: [
                        Container(
                          child: FloatingActionButton(
                            backgroundColor: cleanUpEnable
                                ? Colors.green[300]
                                : Colors.grey[400],
                            onPressed: () {
                              setState(() async {
                                if (cleanUpEnable) {
                                  for (var item in order.items) {
                                    if (item.status == "Eating") {
                                      item.status = "Send back";
                                    }
                                  }
                                  await OrderRepository(
                                          id: id,
                                          table: table,
                                          isLogin: true,
                                          restaurantId: 'Restaurant A')
                                      .updateOrder(order: order);
                                  cleanUpEnable = false;
                                }
                              });
                            },
                            child: Icon(Icons.notifications_active),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: FloatingActionButton(
                            backgroundColor: Colors.black,
                            child: Icon(Icons.shopping_cart_outlined),
                            onPressed: () {
                              QR.toName(AppRoutes.cartPage);
                            },
                          ),
                        ),
                      ]),
                      appBar: AppBar(
                        title: Text(
                          "The Menu",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.black,
                        automaticallyImplyLeading: false,
                        centerTitle: true,
                      ),
                      body: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 30,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text(
                                    "Table number: " + table.toString(),
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
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
                            ),
                            if (order.items.any((element) =>
                                element.status == "Arrived" ||
                                element.status == "Take back"))
                              Expanded(
                                child: Container(
                                  color: Colors.grey[400]?.withOpacity(0.9),
                                ),
                              ),
                            if (order.items.any(
                                (element) => element.status == "Take back"))
                              Container(
                                width: 280,
                                height: 150,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Vui lòng đặt bát đĩa đã ăn lên khay và ấn "Đã trả"'),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.green),
                                        onPressed: () {
                                          setState(() async {
                                            for (var item in order.items) {
                                              if (item.status == "Take back") {
                                                item.status = "Taking back";
                                              }
                                            }
                                            await OrderRepository(
                                                    id: id,
                                                    table: table,
                                                    isLogin: true,
                                                    restaurantId:
                                                        'Restaurant A')
                                                .updateOrder(order: order);
                                          });
                                        },
                                        child: Container(
                                          height: 46,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Đã trả',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            if (order.items
                                .any((element) => element.status == "Arrived"))
                              Container(
                                width: 280,
                                height: 150,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Đồ của bạn đã đến. Vui lòng và lấy đồ ở khay ${stringTray}và ấn nút "Đã nhận"'),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.green),
                                        onPressed: () {
                                          setState(() async {
                                            for (var item in order.items) {
                                              if (item.status == "Arrived") {
                                                item.status = "Eating";
                                                item.tray = null;
                                              }
                                            }
                                            await OrderRepository(
                                                    id: id,
                                                    table: table,
                                                    isLogin: true,
                                                    restaurantId:
                                                        'Restaurant A')
                                                .updateOrder(order: order);
                                          });
                                        },
                                        child: Container(
                                          height: 46,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Đã nhận',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              )
                          ]));
                }));
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
      child: AspectRatio(
        aspectRatio: 400 / 115,
        child: FittedBox(
          child: Container(
            width: 400,
            height: 115,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: Image.network(widget.foodItem['picture'],
                          fit: BoxFit.cover),
                    )),
                const SizedBox(
                  width: 15,
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.foodItem['meal'],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(widget.foodItem['price'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 60),
                        child: Text(
                          widget.foodItem['description'],
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
