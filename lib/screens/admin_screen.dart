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
import 'package:provider/provider.dart';

import '../model/order_model.dart';
import '../widgets/admin_page.dart';
import '../widgets/robot_widget.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int numOfTables = 0;
  int robotCount = 0;

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
    return FutureBuilder<String>(
        future: _loadSession(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Colors.grey[200],
              body: Padding(
                padding: EdgeInsets.all(30),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.all(50),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bàn',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              for (var tableNum = 1;
                                  tableNum < 6 + 1;
                                  tableNum++)
                                Column(
                                  children: [
                                    AspectRatio(
                                        aspectRatio: 264 / 53,
                                        child: TableClass(tableNum)),
                                    SizedBox(
                                      height: 30,
                                    )
                                  ],
                                )
                            ],
                          )),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(flex: 3, child: RobotManagementWidget())
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.abc),
                onPressed: () async {
                  print(await AdminRepository(restaurantId: 'Restaurant A')
                      .getAllCurrentOrders());
                },
              ),
            );
          } else {
            return LinearProgressIndicator();
          }
        });
  }

  Widget RobotManagementWidget() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      padding: EdgeInsets.only(left: 50, right: 50, top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'ROBOT',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 30,
          ),
          Expanded(
            child: Container(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 297 / 504,
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
