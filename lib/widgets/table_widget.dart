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
          .getEachTable(widget.tableNum),
      initialData: OrderModel(true, []),
      child: Builder(builder: (context) {
        var order = Provider.of<OrderModel>(context);
        return InkWell(
          onTap: () {
            order.closed == true
                ? SizedBox()
                : showDialog(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                          backgroundColor: Colors.grey[200],
                          insetPadding: EdgeInsets.symmetric(
                              horizontal: 150, vertical: 50),
                          child: ListView.builder(
                            padding: EdgeInsets.all(30),
                            scrollDirection: Axis.vertical,
                            itemCount: order.items.length,
                            itemBuilder: (context, index) => Card(
                              child:
                                  AdminOrderItem(foodItem: order.items[index]),
                            ),
                          ),
                        ));
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  (order.closed == true) ? Colors.grey[200] : Colors.green[300],
            ),
            child: Center(child: Text(widget.tableNum.toString())),
          ),
        );
      }),
    );
  }
}

class AdminOrderItem extends StatefulWidget {
  AdminOrderItem({Key? key, required this.foodItem}) : super(key: key);
  Item foodItem;
  @override
  State<AdminOrderItem> createState() => _AdminOrderItemState();
}

class _AdminOrderItemState extends State<AdminOrderItem> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  widget.foodItem.meal,
                  style: TextStyle(fontSize: 20),
                )),
            Expanded(
                flex: 1,
                child: Text(
                  'Số lượng: ' + widget.foodItem.amount.toString(),
                  style: TextStyle(fontSize: 20),
                )),
            Expanded(
                flex: 1,
                child: Text(
                  'Giá thành: ' + widget.foodItem.price.toString(),
                  style: TextStyle(fontSize: 20),
                )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_isPressed ? Colors.black : Colors.grey[200],
                    foregroundColor: Colors.white),
                onPressed: () {
                  setState(() {
                    _isPressed = true;
                  });
                },
                child: Container(
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    'Gọi lấy đơn',
                    style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ))
          ],
        ));
  }
}
