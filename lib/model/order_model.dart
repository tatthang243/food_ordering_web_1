import 'dart:convert';

class OrderModel {
  bool closed;
  List<Item> items = [];

  OrderModel(this.closed, this.items);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      json['closed'],
      (json['Items'] as List).map((i) {
        return Item.fromJson(i);
      }).toList(),
    );
  }

  updateItem(Item item) {
    items.add(item);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> jsonList = [];
    for (var item in items) {
      jsonList.add(item.toJson());
    }
    return <String, dynamic>{'closed': closed, 'Items': jsonList};
  }
}

class Item {
  int amount;
  String meal;
  String status;
  DateTime time;
  int price;

  Item(this.amount, this.meal, this.status, this.time, this.price);

  // convert Json to an exercise object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        json['Amount'] as int,
        json['Meal'].toString().trim(),
        json['Status'].toString().trim(),
        json['Timestamp'].toDate(),
        json['Price'] as int);
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'Amount': amount,
        'Meal': meal,
        'Status': status,
        'Timestamp': time,
        'Price': price
      };
}
