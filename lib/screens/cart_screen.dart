import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_ordering_web_1/bloc/cart/cart_bloc.dart';
import 'package:food_ordering_web_1/model/order_model.dart';
import 'package:food_ordering_web_1/repo/order_repo.dart';
import 'package:food_ordering_web_1/utils/food_map.dart';
import 'package:food_ordering_web_1/utils/paths.dart';
import 'package:provider/provider.dart';
import 'package:qlevar_router/qlevar_router.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> map = [];
  var session = FlutterSession();
  bool isLogin = false;
  int table = 0;
  late String restaurantId;
  late String id;
  List<Map<String, dynamic>> currentOrders = [];

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
    return ("_loadSession called = " + table.toString());
  }

  @override
  Widget build(BuildContext context) {
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
                child: Builder(
                  builder: (context) {
                    var orders = Provider.of<OrderModel>(context);
                    for (var order in orders.items) {
                      var results = map.where(
                          (element) => element.containsValue(order.meal));
                      for (var result in results) {
                        result['amount'] = order.amount;
                        result['status'] = order.status;
                        result['time'] = order.time;
                        result['price'] = order.price;
                      }
                      currentOrders = [...currentOrders, ...results];
                    }
                    return Scaffold(
                      appBar: AppBar(
                          backgroundColor: Colors.black,
                          automaticallyImplyLeading: false,
                          centerTitle: true,
                          title: Text("Your Cart"),
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              QR.toName(AppRoutes.menuPage);
                            },
                          )),
                      body: orders.closed || currentOrders.length == 0
                          ? Container(
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                "Your cart is empty",
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: currentOrders.length,
                              itemBuilder: ((context, index) => Card(
                                  child: OrderItem(
                                      foodItem: currentOrders[index]))),
                            ),
                    );
                  },
                ));
            // return BlocBuilder<CartBloc, CartState>(
            //     bloc: CartBloc(
            //         isLogin: isLogin,
            //         table: table,
            //         restaurantId: restaurantId,
            //         id: id)
            //       ..add(CartCreation()),
            //     builder: (context, state) {
            //       if (state is CartLoading) {
            //         return CircularProgressIndicator();
            //       } else if (state is CartSuccess) {
            //         // print(state.orders.items[1].meal);
            //         for (var order in state.orders.items) {
            //           var results = map.where(
            //               (element) => element.containsValue(order.meal));
            //           for (var result in results) {
            //             result['amount'] = order.amount;
            //             result['status'] = order.status;
            //             result['time'] = order.time;
            //             result['price'] = order.price;
            //           }
            //           currentOrders = [...currentOrders, ...results];
            //         }
            //         return Scaffold(
            //           appBar: AppBar(
            //               automaticallyImplyLeading: false,
            //               centerTitle: true,
            //               title: Text("Your Cart"),
            //               leading: IconButton(
            //                 icon: Icon(Icons.arrow_back),
            //                 onPressed: () {
            //                   QR.toName(AppRoutes.menuPage);
            //                 },
            //               )),
            //           body: state.orders.closed
            //               ? Container(
            //                   alignment: Alignment.topCenter,
            //                   padding: EdgeInsets.only(top: 10),
            //                   child: Text(
            //                     "Your cart is empty",
            //                     style: TextStyle(fontStyle: FontStyle.italic),
            //                   ),
            //                 )
            //               : ListView.builder(
            //                   scrollDirection: Axis.vertical,
            //                   itemCount: currentOrders.length,
            //                   itemBuilder: ((context, index) => Card(
            //                       child: OrderItem(
            //                           foodItem: currentOrders[index]))),
            //                 ),
            //         );
            //       } else if (state is CartFail) {
            //         return Container(
            //           child: Text(state.message),
            //         );
            //       } else {
            //         return SizedBox();
            //       }
            //     });
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  OrderItem({required Map<String, dynamic> foodItem}) {
    print(foodItem);
    return Container(
      height: 100,
      width: double.infinity,
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
                child: Image.network(foodItem['picture']),
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
                  foodItem['meal'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Số lượng: ' +
                          foodItem['amount'].toString() +
                          "\t Trạng thái: " +
                          foodItem['status'].toString() +
                          '\nThời gian: ' +
                          foodItem['time'].toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                    ),
                    Text('Giá: ' + foodItem['price'].toString()),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
