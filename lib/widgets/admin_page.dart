import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../repo/admin_repo.dart';

class AdminPage extends StatefulWidget {
  AdminPage({Key? key, required this.allOrders}) : super(key: key);
  Map<dynamic, dynamic> allOrders;
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    // var tempList = [1, 2, 3, 4, 5, 6, 7, 8];
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Page"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 2,
          mainAxisSpacing: screenWidth / 30,
          crossAxisSpacing: screenWidth / 20,
          padding: EdgeInsets.all(screenWidth / 20),
          children: [
            for (var tableNum in widget.allOrders.keys) TableWidget(tableNum)
          ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.abc),
        onPressed: () async {
          print(await AdminRepository(restaurantId: 'Restaurant A')
              .getAllCurrentOrders());
        },
      ),
    );
  }

  InkWell TableWidget(tableNum) {
    bool isHovering = false;
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) => SizedBox(
                  height: 50,
                  width: 50,
                ));
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: (widget.allOrders[tableNum] == null)
              ? Colors.grey
              : Colors.green[300],
        ),
        child: Center(child: Text(tableNum.toString())),
      ),
    );
  }
}
