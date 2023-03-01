import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_ordering_web_1/bloc/get_all_bloc/get_all_bloc.dart';
import 'package:food_ordering_web_1/repo/admin_repo.dart';
import 'package:food_ordering_web_1/widgets/table_widget.dart';
import 'package:multiple_stream_builder/multiple_stream_builder.dart';
import 'package:provider/provider.dart';
import 'package:roslibdart/roslibdart.dart';

import '../model/order_model.dart';
import '../widgets/robot_widget.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int numOfTables = 0;
  int robotCount = 0;
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
  }

  Future<void> sendBack(
      {required int start,
      required int destination,
      required DateTime time}) async {
    Map<String, dynamic> _jsonMsg = {
      "destination": destination,
      "start": start,
      "meal": 'cleaning',
      "time": time
    };
    await item.publish({"data": _jsonMsg.toString()});
  }

  Future<String> _loadSession() async {
    numOfTables =
        await AdminRepository(restaurantId: 'Restaurant A').getNumberOfTables();
    robotCount =
        await AdminRepository(restaurantId: 'Restaurant A').getRobotCount();
    return ("_loadSession called numbOfTables = " + numOfTables.toString());
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var gridWidth = screenWidth * 2 / 3;
    var robotWidth = screenWidth / 3;
    print("width " + screenWidth.toString());
    print("height: " + screenHeight.toString());

    return FutureBuilder<String>(
        future: _loadSession(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.grey[200],
              body: Center(
                child: AspectRatio(
                  aspectRatio: 1440 / 824,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Container(
                      height: 824,
                      width: 1440,
                      padding:
                          EdgeInsets.symmetric(horizontal: 74, vertical: 54),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  width: 334,
                                  height: 558,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20)),
                                  padding: EdgeInsets.only(top: 34),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 24),
                                        child: Text(
                                          'BÀN',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 36,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                      ),
                                      for (var tableNum = 1;
                                          tableNum < 6 + 1;
                                          tableNum++)
                                        Column(
                                          children: [
                                            AspectRatio(
                                                aspectRatio: 264 / 53,
                                                child: TableClass(tableNum)),
                                            Divider(
                                              height: 1,
                                              thickness: 1,
                                            )
                                          ],
                                        )
                                    ],
                                  )),
                              SizedBox(
                                height: 38,
                              ),
                              SumOfAllOrders()
                            ],
                          ),
                          SizedBox(
                            width: 44,
                          ),
                          Container(width: 914, child: RobotManagementWidget())
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return LinearProgressIndicator();
          }
        });
  }

  Widget SumOfAllOrders() {
    return StreamBuilder6<OrderModel, OrderModel, OrderModel, OrderModel,
            OrderModel, OrderModel>(
        streams: StreamTuple6(
            AdminRepository(restaurantId: 'Restaurant A').getEachTable(1),
            AdminRepository(restaurantId: 'Restaurant A').getEachTable(2),
            AdminRepository(restaurantId: 'Restaurant A').getEachTable(3),
            AdminRepository(restaurantId: 'Restaurant A').getEachTable(4),
            AdminRepository(restaurantId: 'Restaurant A').getEachTable(5),
            AdminRepository(restaurantId: 'Restaurant A').getEachTable(6)),
        initialData: InitialDataTuple6(null, null, null, null, null, null),
        builder: ((context, snapshots) {
          return FutureBuilder<int>(
              future: sumAll(),
              builder: (context, snapshot) {
                return Container(
                  height: 120,
                  width: 334,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.only(top: 24, left: 24, right: 47),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TỔNG ĐƠN',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        (snapshot.data ?? 0).toString(),
                        style: TextStyle(fontSize: 40),
                      )
                    ],
                  ),
                );
              });
        }));
  }

  Future<int> sumAll() async {
    var sumAll = 0;
    await AdminRepository(restaurantId: 'Restaurant A')
        .getAllCurrentOrders()
        .then((value) => value.forEach((key, value) {
              if (value != null) {
                for (var element in value.items) {
                  sumAll += element.amount;
                }
                if (value.items
                    .any((element) => element.status == 'Send back')) {
                  sendBack(
                      destination: 0,
                      start: value.items[0].table,
                      time: DateTime.now());
                }
              }
            }));
    return sumAll;
  }

  Widget RobotManagementWidget() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 34, left: 45),
            child: Text(
              'ROBOT',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 34),
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 258 / 620,
                crossAxisSpacing: 30,
                children: [
                  for (int robot = 1; robot < robotCount + 1; robot++)
                    Container(child: RobotWidget(robot, numOfTables))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
