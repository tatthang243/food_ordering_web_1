import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RobotWidget extends StatefulWidget {
  RobotWidget(this.robot, this.numOfTables, {Key? key}) : super(key: key);
  int robot;
  int numOfTables;
  @override
  State<RobotWidget> createState() => _RobotWidgetState();
}

class _RobotWidgetState extends State<RobotWidget> {
  var tempTask = [
    {'meal': 'Chicken', 'table': 2, 'tray': null},
    {'meal': 'Chicken', 'table': 2, 'tray': null},
    {'meal': 'Beef', 'table': 2, 'tray': null},
    {'meal': 'Chicken', 'table': 3, 'tray': null},
    {'meal': 'Pizza', 'table': 1, 'tray': null},
    {'meal': 'Steak', 'table': 4, 'tray': null},
    {'meal': 'Ribs', 'table': 4, 'tray': null},
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Robot' + widget.robot.toString(),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Vi tri',
                      style:
                          TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                    )
                  ],
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      if (tempTask.any((element) => element['tray'] == null)) {
                        print('select all table');
                      } else {
                        print(tempTask);
                      }
                    },
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: Text(
                        'Dispatch',
                        style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold),
                      ),
                    ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Task:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: tempTask.length,
                  itemBuilder: ((context, index) => Card(
                          child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 7,
                                  ),
                                  Text(
                                    tempTask[index]['meal'].toString(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text('Table ' +
                                      tempTask[index]['table'].toString())
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: DropdownButton(
                                  isExpanded: true,
                                  hint: tempTask[index]['tray'] == null
                                      ? Text('Select table')
                                      : Text('Tray ' +
                                          tempTask[index]['tray'].toString()),
                                  items: List.generate(widget.numOfTables,
                                      (index) => index + 1).map((val) {
                                    return DropdownMenuItem<int>(
                                      value: val,
                                      child: Text('Tray ' + val.toString()),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      tempTask[index]['tray'] = val;
                                    });
                                  }),
                            )
                          ],
                        ),
                      ))),
                ),
              ),
            )
          ],
        ));
  }
}
