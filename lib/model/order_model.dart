import 'dart:convert';

class OrderModel {
  bool closed;
  List<Item> items = [];
  String id;

  OrderModel(this.closed, this.items, this.id);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
        json['closed'],
        (json['Items'] as List).map((i) {
          return Item.fromJson(i);
        }).toList(),
        json['id']);
  }

  updateItem(Item item) {
    items.add(item);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> jsonList = [];
    for (var item in items) {
      jsonList.add(item.toJson());
    }
    return <String, dynamic>{'closed': closed, 'Items': jsonList, 'id': id};
  }
}

class Item {
  int table;
  // int amount;
  String meal;
  String status;
  DateTime time;
  int price;
  int? tray;
  int? robot;

  Item(this.table, this.meal, this.status, this.time, this.price, this.tray,
      this.robot);

  // convert Json to an exercise object
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
        json['Table'] as int,
        // json['Amount'] as int,
        json['Meal'].toString().trim(),
        json['Status'].toString().trim(),
        json['Timestamp'].toDate(),
        json['Price'] as int,
        json['tray'] as int?,
        json['robot'] as int?);
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'Table': table,
        // 'Amount': amount,
        'Meal': meal,
        'Status': status,
        'Timestamp': time,
        'Price': price,
        'tray': tray,
        'robot': robot
      };
}
