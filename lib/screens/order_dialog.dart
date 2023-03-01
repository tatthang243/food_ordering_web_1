import 'package:flutter/material.dart';
import 'package:food_ordering_web_1/model/order_model.dart';
import 'package:food_ordering_web_1/repo/order_repo.dart';
import 'package:quantity_input/quantity_input.dart';

class OrderDialog extends StatefulWidget {
  const OrderDialog(
      {Key? key,
      required this.foodItem,
      required this.isLogin,
      required this.table,
      required this.restaurantId,
      required this.id})
      : super(key: key);
  final Map<String, dynamic> foodItem;
  final bool isLogin;
  final int table;
  final String restaurantId;
  final String id;
  @override
  State<OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<OrderDialog> {
  int orderAmount = 0;
  late Item item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        // insetPadding: EdgeInsets.symmetric(vertical: 90, horizontal: 50),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: AspectRatio(
          aspectRatio: 400 / 560,
          child: FittedBox(
            child: Container(
              height: 560,
              width: 400,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Scaffold(
                      body: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          alignment: Alignment.centerRight,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  child: Image.network(
                                    widget.foodItem['picture'],
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    widget.foodItem['meal'],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(widget.foodItem['price'].toString()),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(widget.foodItem['description']),
                                ],
                              ),
                              SizedBox(height: 40),
                              Text('Total: ' +
                                  (widget.foodItem['price'] * orderAmount)
                                      .toString()),
                              SizedBox(height: 10),
                              QuantityInput(
                                  buttonColor: Colors.white,
                                  iconColor: Colors.grey.shade500,
                                  acceptsZero: true,
                                  acceptsNegatives: false,
                                  type: QuantityInputType.int,
                                  value: orderAmount,
                                  onChanged: (value) => setState(() =>
                                      orderAmount = int.parse(
                                          value.replaceAll(',', '')))),
                              SizedBox(
                                height: 8,
                              ),
                              ElevatedButton(
                                onPressed: (() {
                                  if (orderAmount != 0) {
                                    item = Item(
                                        widget.table,
                                        orderAmount,
                                        widget.foodItem['meal'],
                                        'Pending',
                                        DateTime.now(),
                                        widget.foodItem['price'] * orderAmount,
                                        null);
                                    OrderRepository(
                                            id: widget.id,
                                            restaurantId: widget.restaurantId,
                                            table: widget.table,
                                            isLogin: widget.isLogin)
                                        .addOrder(item: item);
                                  }
                                }),
                                child: Container(
                                    width: double.infinity,
                                    height: 40,
                                    alignment: Alignment.center,
                                    child: Text("Order")),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black,
                                  // side: BorderSide(color: Colors.yellow, width: 5),
                                  textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontStyle: FontStyle.normal),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ))),
            ),
          ),
        ));
  }
}
