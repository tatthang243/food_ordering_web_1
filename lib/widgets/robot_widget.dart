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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 182,
            height: 138,
            color: Colors.amber,
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
                'Trạng thái robot',
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
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: tempTask.length,
              itemBuilder: ((context, index) => Card(
                      child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tempTask[index]['meal'].toString() +
                              ',  ' +
                              'Table ' +
                              tempTask[index]['table'].toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                        DropdownButton(
                            isExpanded: true,
                            hint: tempTask[index]['tray'] == null
                                ? Text('Select table')
                                : Text('Tray ' +
                                    tempTask[index]['tray'].toString()),
                            items: List.generate(
                                    widget.numOfTables, (index) => index + 1)
                                .map((val) {
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
                      ],
                    ),
                  ))),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.black),
              onPressed: () {
                if (tempTask.any((element) => element['tray'] == null)) {
                  print('select all table');
                } else {
                  print(tempTask);
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
