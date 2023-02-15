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
              appBar: AppBar(
                title: Text("Admin Page"),
                automaticallyImplyLeading: false,
                centerTitle: true,
              ),
              body: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                        mainAxisSpacing: screenWidth / 30, //fix spacing later
                        crossAxisSpacing: screenWidth / 20, //fix spacing laters
                        padding: EdgeInsets.all(screenWidth / 30),
                        children: [
                          for (var tableNum = 1; tableNum < 6 + 1; tableNum++)
                            TableClass(tableNum)
                        ]),
                  ),
                  Expanded(flex: 1, child: RobotManagementWidget())
                ],
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
    return Column(
      children: [
        for (int robot = 1; robot < robotCount + 1; robot++)
          Expanded(
            flex: 1,
            child: RobotWidget(robot, numOfTables),
          )
      ],
    );
  }
}
