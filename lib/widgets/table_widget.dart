import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_web_1/model/order_model.dart';
import 'package:food_ordering_web_1/repo/admin_repo.dart';
import 'package:provider/provider.dart';

class TableClass extends StatefulWidget {
  TableClass(this.tableNum, {Key? key}) : super(key: key);
  late int tableNum;
  @override
  State<TableClass> createState() => _TableClassState();
}

class _TableClassState extends State<TableClass> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<OrderModel>.value(
      value: AdminRepository(restaurantId: 'Restaurant A')
          .getEachTables(widget.tableNum),
      initialData: OrderModel(true, []),
      child: Builder(builder: (context) {
        var order = Provider.of<OrderModel>(context);
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
              color: (order.closed == true) ? Colors.grey : Colors.green[300],
            ),
            child: Center(child: Text(widget.tableNum.toString())),
          ),
        );
      }),
    );
  }
}
