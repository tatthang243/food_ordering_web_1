import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_ordering_web_1/model/order_model.dart';

class AdminModel {
  List<Table> tables = [];
  AdminModel(this.tables);
  void addTable(Table table) {
    tables.add(table);
  }
}

class Table {
  int tableNum;
  OrderModel order;
  Table(this.tableNum, this.order);
}
