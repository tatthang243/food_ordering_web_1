import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_web_1/model/order_model.dart';
import 'package:food_ordering_web_1/repo/admin_repo.dart';
import 'package:food_ordering_web_1/repo/order_repo.dart';
import 'package:provider/provider.dart';
import 'package:roslibdart/roslibdart.dart';

class TableClass extends StatefulWidget {
  TableClass(this.tableNum, {Key? key}) : super(key: key);
  late int tableNum;
  @override
  State<TableClass> createState() => _TableClassState();
}

class _TableClassState extends State<TableClass> {
  late Ros ros;
  late Topic item;

  @override
  void initState() {
    ros = Ros(url: 'ws://localhost:9090');
    item = Topic(
        ros: ros,
        name: '/item',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    super.initState();

    ros.connect();
    // Timer.periodic(const Duration(milliseconds: 100), (timer) async {
    //   await publishOrder();
    //   setState(() {});
    // });
  }

  // OrderModel orderToBePublished = OrderModel(true, [], '');

  Future<void> publishOrder(Item itemToBePublished) async {
    Map<String, dynamic> _jsonMsg = {
      "destination": widget.tableNum,
      "start": 0,
      "meal": itemToBePublished.meal + ',' + itemToBePublished.time.toString(),
      // "amount": itemToBePublished.amount,
    };
    // for (int i = 0; i < itemToBePublished.amount; i++) {
    await item.publish({"data": json.encode(_jsonMsg)});
    // }
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<OrderModel>.value(
      value: AdminRepository(restaurantId: 'Restaurant A')
          .getEachTable(widget.tableNum),
      initialData: OrderModel(true, [], ''),
      child: Builder(builder: (context) {
        Map<String, int> tableStatus = {
          "Pending": 0,
          "Preparing": 0,
          "Delivering": 0,
          "Eating": 0
        };
        var order = Provider.of<OrderModel>(context);
        for (var item in order.items) {
          if (item.status == "Preparing") {
            tableStatus["Preparing"] = tableStatus["Preparing"]! + 1;
          } else if (item.status == "Delivering" ||
              item.status == "Ready" ||
              item.status == "Arrived") {
            tableStatus["Delivering"] = tableStatus["Delivering"]! + 1;
          } else if (item.status == "Eating" ||
              item.status == "Finished" ||
              item.status == "Send back" ||
              item.status == "Received back") {
            tableStatus["Eating"] = tableStatus["Eating"]! + 1;
          } else if (item.status == "Pending") {
            tableStatus["Pending"] = tableStatus["Pending"]! + 1;
          } else {
            continue;
          }
        }
        return InkWell(
          onTap: () {
            order.closed == true
                ? SizedBox()
                : AdminOrderDialog(context, order);
          },
          child: Container(
            // decoration: BoxDecoration(
            //   color:
            //       (order.closed == true) ? Colors.grey[200] : Colors.green[300],
            // ),
            padding: EdgeInsets.symmetric(horizontal: 38),
            child: Stack(children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Bàn " + widget.tableNum.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        Text(tableStatus["Pending"].toString(),
                            style: TextStyle(fontSize: 16)),
                        SizedBox(
                          width: 3,
                        ),
                        Icon(Icons.hourglass_empty_outlined)
                      ],
                    ),
                    Row(
                      children: [
                        Text(tableStatus["Preparing"].toString(),
                            style: TextStyle(fontSize: 16)),
                        SizedBox(
                          width: 3,
                        ),
                        Container(
                            width: 21,
                            height: 24,
                            child: Image.asset('resources/cook2 1.png'))
                      ],
                    ),
                    Row(
                      children: [
                        Text(tableStatus["Delivering"].toString(),
                            style: TextStyle(fontSize: 16)),
                        SizedBox(
                          width: 3,
                        ),
                        Container(
                            width: 21,
                            height: 24,
                            child: Image.asset('resources/image 3.png'))
                      ],
                    ),
                    Row(
                      children: [
                        Text(tableStatus["Eating"].toString(),
                            style: TextStyle(fontSize: 16)),
                        SizedBox(
                          width: 3,
                        ),
                        Container(
                            width: 21,
                            height: 24,
                            child: Image.asset('resources/image 4.png'))
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                color: (order.closed == true)
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white.withOpacity(0),
              ),
            ]),
          ),
        );
      }),
    );
  }

  Future<dynamic> AdminOrderDialog(BuildContext context, OrderModel order) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
            backgroundColor: Colors.grey[200],
            insetPadding: EdgeInsets.symmetric(horizontal: 150, vertical: 50),
            child: StreamProvider<OrderModel>.value(
              value: AdminRepository(restaurantId: 'Restaurant A')
                  .getEachTable(widget.tableNum),
              initialData: order,
              child: Builder(builder: (context) {
                var order = Provider.of<OrderModel>(context);
                var sumOrder = 0;
                for (var item in order.items) {
                  sumOrder += item.price;
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 35, top: 30),
                      child: Text("Order ID: #" + order.id,
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding:
                            EdgeInsets.only(left: 30, right: 30, bottom: 30),
                        scrollDirection: Axis.vertical,
                        itemCount: order.items.length,
                        itemBuilder: (context, index) => Card(
                          child: Container(
                              height: 50,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        order.items[index].meal,
                                        style: TextStyle(fontSize: 16),
                                      )),
                                  // Expanded(
                                  //     flex: 2,
                                  //     child: Text(
                                  //       'Amount: ' +
                                  //           order.items[index].amount
                                  //               .toString(),
                                  //       style: TextStyle(fontSize: 16),
                                  //     )),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Price: ' +
                                            order.items[index].price.toString(),
                                        style: TextStyle(fontSize: 16),
                                      )),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        order.items[index].time.toString(),
                                        style: TextStyle(fontSize: 16),
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Status: ' +
                                            order.items[index].status
                                                .toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      )),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: order.items[index].status ==
                                                'Pending'
                                            ? Colors.orange
                                            : Colors.grey[200],
                                      ),
                                      onPressed: () {
                                        setState(() async {
                                          if (order.items[index].status ==
                                              "Pending") {
                                            order.items[index].status =
                                                "Preparing";
                                            await OrderRepository(
                                                    id: order.id,
                                                    table: widget.tableNum,
                                                    isLogin: true,
                                                    restaurantId:
                                                        'Restaurant A')
                                                .updateOrder(order: order);
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Preparing',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: order.items[index].status ==
                                                "Preparing"
                                            ? Colors.green
                                            : Colors.grey[200],
                                      ),
                                      onPressed: () {
                                        setState(() async {
                                          if (order.items[index].status ==
                                              "Preparing") {
                                            order.items[index].status = "Ready";
                                            await OrderRepository(
                                                    id: order.id,
                                                    table: widget.tableNum,
                                                    isLogin: true,
                                                    restaurantId:
                                                        'Restaurant A')
                                                .updateOrder(order: order);
                                          }
                                          await publishOrder(
                                              order.items[index]);
                                        });
                                      },
                                      child: Container(
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Ready',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() async {
                                          // _isPressed = true;
                                          order.items.removeAt(index);
                                          await OrderRepository(
                                                  id: order.id,
                                                  table: widget.tableNum,
                                                  isLogin: true,
                                                  restaurantId: 'Restaurant A')
                                              .updateOrder(order: order);
                                        });
                                      },
                                      child: Container(
                                        height: 30,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ))
                                ],
                              )),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      height: 50,
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Sum :' + sumOrder.toString(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.black,
                              ),
                              onPressed: () {
                                setState(() async {
                                  // _isPressed = true;
                                  order.closed = true;
                                  await OrderRepository(
                                          id: order.id,
                                          table: widget.tableNum,
                                          isLogin: true,
                                          restaurantId: 'Restaurant A')
                                      .updateOrder(order: order);
                                });
                              },
                              child: Container(
                                height: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  'Check out',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                        ],
                      ),
                    )
                  ],
                );
              }),
            )));
  }
}
