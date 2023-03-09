import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_web_1/repo/admin_repo.dart';
import 'package:roslibdart/roslibdart.dart';

class RobotWidget extends StatefulWidget {
  RobotWidget(this.robot, this.numOfTables, {Key? key}) : super(key: key);
  int robot;
  int numOfTables;
  @override
  State<RobotWidget> createState() => _RobotWidgetState();
}

class _RobotWidgetState extends State<RobotWidget> {
  late Ros ros;
  late Topic task;
  late Topic dispatch;
  bool newValue = false;
  late Topic robotStatus;

  @override
  void initState() {
    ros = Ros(url: 'ws://localhost:9090');
    task = Topic(
        ros: ros,
        name: '/task${widget.robot}',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);
    dispatch = Topic(
        ros: ros,
        name: '/robot${widget.robot}/confirm',
        type: "std_msgs/Bool",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);

    robotStatus = Topic(
        ros: ros,
        name: '/robot${widget.robot}/status',
        type: "std_msgs/String",
        reconnectOnClose: true,
        queueLength: 0,
        queueSize: 1000);
    super.initState();
    ros.connect();

    Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      await task.subscribe(subscribeHandler1);
      await robotStatus.subscribe(subscribeHandler2);
      // await task3.subscribe(subscribeHandler3);
      setState(() {});
    });
  }

  Future<void> dispatchRobot() async {
    await dispatch.publish({"data": true});
  }

  String msgReceived = '';
  var jsonTask = [];

  Future<void> subscribeHandler1(Map<String, dynamic> msg) async {
    msgReceived = msg['data'].toString();
    // var jsonTask = json.decode(msgReceived1);
    // print('checking json');
    // print(jsonTask[0]['meal']);
    // setState(() {});
    // json.encode(jsonTask);
    try {
      jsonTask = json.decode(msgReceived);
    } catch (e) {}
    // print("at json " + json.decode(msgReceived1)[0]['meal']);
    print(json.decode(msgReceived));
    newValue = true;
  }

  String statusReceived = '';
  Future<void> subscribeHandler2(Map<String, dynamic> msg) async {
    statusReceived = msg['data'].toString();
  }

  var tempTask = [
    {
      'meal': 'Chicken',
      'table': 2,
      'time': DateTime.now().toString(),
      'tray': null
    },
    {
      'meal': 'Chicken',
      'table': 2,
      'time': DateTime.now().toString(),
      'tray': null
    },
    {
      'meal': 'Chicken',
      'table': 2,
      'time': DateTime.now().toString(),
      'tray': null
    },
  ];

  @override
  Widget build(BuildContext context) {
    // print(json.decode(json.encode(tempTask)));
    // print(tempTask.where((element) => element['meal'] == 'Chicken'));
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Text(msgReceived1),
          Container(
            width: 182,
            height: 138,
            child: Image.asset(
              'resources/robot ${widget.robot.toString()}.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '•',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                statusReceived == '' ? 'Trạng thái chờ' : statusReceived,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Container(
            height: 350,
            width: 258,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            child: Stack(children: [
              ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: jsonTask.length,
                itemBuilder: ((context, index) => Card(
                        child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jsonTask[index]['meal'].toString() +
                                ',  ' +
                                'Table ' +
                                jsonTask[index]['table'].toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                          DropdownButton(
                              isExpanded: true,
                              hint: jsonTask[index]['tray'] == null
                                  ? Text('Select table')
                                  : Text('Tray ' +
                                      jsonTask[index]['tray'].toString()),
                              items: List.generate(3, (index) => index + 1)
                                  .map((val) {
                                return DropdownMenuItem<int>(
                                  value: val,
                                  child: Text('Tray ' + val.toString()),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  jsonTask[index]['tray'] = val;
                                });
                              }),
                        ],
                      ),
                    ))),
              ),
              if (!newValue)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.shade200.withAlpha(125),
                )
            ]),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: newValue ? Colors.black : Colors.grey[400]),
              onPressed: () async {
                if (newValue) {
                  if (jsonTask.any((element) => element['tray'] == null)) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                            alignment: Alignment.center,
                            child: Container(
                                height: 100,
                                width: 200,
                                alignment: Alignment.center,
                                child: Text('select all trays'))));
                  } else {
                    // print(jsonTask);
                    // var timeList = [];
                    // for (var element in jsonTask) {
                    //   if (!timeList.contains(element['time'])) {
                    //     timeList.add(element['time']);
                    //   }
                    // }
                    // for (var tempTime in timeList) {
                    //   int tray = 0;
                    //   int tempTable = 0;
                    //   for (var tempItem in jsonTask
                    //       .where((element) => element['time'] == tempTime)) {
                    //     tray = tempItem['tray'] as int;
                    //     // print(tempItem);
                    //     tempTable = tempItem['table'] as int;
                    //   }
                    //   print('table: ' +
                    //       tempTable.toString() +
                    //       'time: ' +
                    //       tempTime +
                    //       '\t' +
                    //       tray.toString());
                    for (var element in jsonTask) {
                      print('table: ' +
                          element['table'].toString() +
                          'time: ' +
                          element['time'] +
                          '\t' +
                          element['tray'].toString());
                      await AdminRepository(restaurantId: 'Restaurant A')
                          .updateItemTrayAndRobot(
                              table: element['table'],
                              time: DateTime.parse(element['time']),
                              tray: element['tray'],
                              robot: widget.robot);
                      setState(() {
                        newValue = false;
                      });
                    }
                  }
                  await dispatchRobot();
                }
              },
              child: Container(
                height: 46,
                width: 258,
                alignment: Alignment.center,
                child: Text(
                  'Dispatch',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
