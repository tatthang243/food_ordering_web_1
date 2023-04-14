import 'dart:async';
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
  late Topic dispatch_robot_1;
  late Topic dispatch_robot_2;
  late Topic dispatch_robot_3;
  late Topic robot_1_arrived;
  late Topic robot_2_arrived;
  late Topic robot_3_arrived;

  @override
  void initState() {
    ros = Ros(url: 'ws://192.168.0.100:9090');
    // ros = Ros(url: 'ws://localhost:9090');
    item = Topic(
        ros: ros,
        name: '/item',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    dispatch_robot_1 = Topic(
        ros: ros,
        name: '/robot1/good_confirmation',
        type: "std_msgs/Bool",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);
    dispatch_robot_2 = Topic(
        ros: ros,
        name: '/robot2/good_confirmation',
        type: "std_msgs/Bool",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);
    dispatch_robot_3 = Topic(
        ros: ros,
        name: '/robot3/good_confirmation',
        type: "std_msgs/Bool",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);
    robot_1_arrived = Topic(
        ros: ros,
        name: '/robot1/arrived_confirmation',
        type: "std_msgs/Bool",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);
    robot_2_arrived = Topic(
        ros: ros,
        name: '/robot2/arrived_confirmation',
        type: "std_msgs/Bool",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);
    robot_3_arrived = Topic(
        ros: ros,
        name: '/robot3/arrived_confirmation',
        type: "std_msgs/Bool",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);

    Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      await robot_1_arrived.subscribe(subscribeHandler1);
      await robot_2_arrived.subscribe(subscribeHandler2);
      await robot_3_arrived.subscribe(subscribeHandler3);
    });

    super.initState();
    ros.connect();
  }

  bool robot1ArrivedCleaning = false;
  bool robot1Arrived = false;
  Future<void> subscribeHandler1(Map<String, dynamic> msg) async {
    robot1Arrived = msg['data'];
    // print('data' + msg['data']);
    if (robot1Arrived) {
      robot1ArrivedCleaning =
          await AdminRepository(restaurantId: 'Restaurant A')
              .updateRobotArrivedAtCustomer(robot: 1);
      robot1Arrived = false;
    }

    setState(() {});
  }

  bool robot2ArrivedCleaning = false;
  bool robot2Arrived = false;
  Future<void> subscribeHandler2(Map<String, dynamic> msg) async {
    robot2Arrived = msg['data'];
    // print('data' + msg['data']);
    if (robot2Arrived) {
      robot2ArrivedCleaning =
          await AdminRepository(restaurantId: 'Restaurant A')
              .updateRobotArrivedAtCustomer(robot: 2);
      robot2Arrived = false;
    }

    setState(() {});
  }

  bool robot3ArrivedCleaning = false;
  bool robot3Arrived = false;
  Future<void> subscribeHandler3(Map<String, dynamic> msg) async {
    robot3Arrived = msg['data'];
    // print('data type:' + msg['data'].runtimeType.toString());
    if (robot3Arrived) {
      robot3ArrivedCleaning =
          await AdminRepository(restaurantId: 'Restaurant A')
              .updateRobotArrivedAtCustomer(robot: 3);
      robot3Arrived = false;
    }
    setState(() {});
  }

  Future<void> dispatchRobot1() async {
    await dispatch_robot_1.publish({"data": true});
  }

  Future<void> dispatchRobot2() async {
    await dispatch_robot_2.publish({"data": true});
  }

  Future<void> dispatchRobot3() async {
    await dispatch_robot_3.publish({"data": true});
  }

  Future<void> sendBack(
      {required int start,
      required int destination,
      required DateTime time}) async {
    Map<String, dynamic> _jsonMsg = {
      "destination": destination,
      "start": start,
      "meal": 'cleaning,' + time.toString(),
    };
    await item.publish({"data": json.encode(_jsonMsg)});
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
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await AdminRepository(restaurantId: 'Restaurant A')
                      .updateRobotArrivedAtCustomer(robot: 1);
                },
                child: Icon(Icons.notifications_active),
              ),
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
                      child: Stack(alignment: Alignment.center, children: [
                        Row(
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
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    padding: EdgeInsets.only(top: 34),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                            Container(
                                width: 914, child: RobotManagementWidget())
                          ],
                        ),
                        if (robot1ArrivedCleaning ||
                            robot2ArrivedCleaning ||
                            robot3ArrivedCleaning)
                          Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.grey[200]?.withOpacity(0.9),
                          ),
                        if (robot1ArrivedCleaning)
                          Container(
                            width: 280,
                            height: 150,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Vui lòng lấy bát đĩa bẩn trên khay của robot 1 và ấn "Đã lấy"'),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.green),
                                    onPressed: () async {
                                      await AdminRepository(
                                              restaurantId: 'Restaurant A')
                                          .updateRobotArrivedWithCleaningAtOwner(
                                              robot: 1);
                                      await dispatchRobot1();
                                      setState(() {
                                        robot1ArrivedCleaning = false;
                                      });
                                    },
                                    child: Container(
                                      height: 46,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Đã lấy',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        if (robot2ArrivedCleaning)
                          Container(
                            width: 280,
                            height: 150,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Vui lòng lấy bát đĩa bẩn trên khay của robot 2 và ấn "Đã lấy"'),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.green),
                                    onPressed: () async {
                                      await AdminRepository(
                                              restaurantId: 'Restaurant A')
                                          .updateRobotArrivedWithCleaningAtOwner(
                                              robot: 2);
                                      await dispatchRobot2();
                                      setState(() {
                                        robot2ArrivedCleaning = false;
                                      });
                                    },
                                    child: Container(
                                      height: 46,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Đã lấy',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        if (robot3ArrivedCleaning)
                          Container(
                            width: 280,
                            height: 150,
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Vui lòng lấy bát đĩa bẩn trên khay của robot 3 và ấn "Đã lấy"'),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.green),
                                    onPressed: () async {
                                      await AdminRepository(
                                              restaurantId: 'Restaurant A')
                                          .updateRobotArrivedWithCleaningAtOwner(
                                              robot: 3);
                                      await dispatchRobot3();
                                      setState(() {
                                        robot3ArrivedCleaning = false;
                                      });
                                    },
                                    child: Container(
                                      height: 46,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Đã lấy',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                      ]),
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

  Future<void> showAlert() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Test"),
            content: const Text("This is a test dialog"),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"))
            ],
          );
        });
  }

  Future<int> sumAll() async {
    var sumAll = 0;
    await AdminRepository(restaurantId: 'Restaurant A')
        .getAllCurrentOrders()
        .then((value) => value.forEach((key, value) async {
              bool needUpdate = false;
              if (value != null) {
                int? robotToDispatch = 0;
                for (var element in value.items) {
                  sumAll += 1;
                  if (element.status == 'Eating' && element.robot != null) {
                    robotToDispatch = element.robot;
                    element.robot = null;
                    needUpdate = true;
                  }
                  // if (element.status == 'Arrived back' &&
                  //     element.robot != null) {
                  //   robotToDispatch = element.robot;
                  //   element.status = 'Taken back';
                  //   element.robot = null;
                  //   needUpdate = true;
                  // }
                }
                if (robotToDispatch == 1) {
                  await dispatchRobot1();
                }
                if (robotToDispatch == 2) {
                  await dispatchRobot2();
                }
                if (robotToDispatch == 3) {
                  await dispatchRobot3();
                }
                if (needUpdate) {
                  AdminRepository(restaurantId: 'Restaurant A')
                      .updateOrder(value, key as int);
                  needUpdate = false;
                }
                if (value.items
                    .any((element) => element.status == 'Send back')) {
                  await sendBack(
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
