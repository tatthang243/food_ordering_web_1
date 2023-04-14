import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/order_model.dart';

class AdminRepository {
  AdminRepository({required this.restaurantId});
  String restaurantId;
  late int numOfTables;
  late Map<dynamic, OrderModel?> allCurrentOrders = {};
  late Map<int, Stream<dynamic>> allStreamOrders = {};
  late final _docRef =
      FirebaseFirestore.instance.collection('Main').doc(restaurantId);

  Future<int> getNumberOfTables() async {
    return _docRef.get().then((value) => (value['tableCount']) as int);
  }

  Future<int> getRobotCount() async {
    return _docRef.get().then((value) => (value['robotCount']) as int);
  }

  Map<int, Stream<dynamic>> getDocumentSnapshot() {
    numOfTables = 3;
    for (var table = 1; table < numOfTables + 1; table++) {
      allStreamOrders[table] = _docRef
          .collection('table' + table.toString())
          .where('closed', isEqualTo: false)
          .limit(1)
          .snapshots();
    }
    return allStreamOrders;
  }

  Stream<OrderModel> getEachTable(int table) {
    return _docRef
        .collection('table' + table.toString())
        .where('closed', isEqualTo: false)
        .limit(1)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => (OrderModel.fromJson(e.data()))).first);
  }

  Stream<Map<String, dynamic>> getSumOfAllOrders() {
    Map<dynamic, Stream<OrderModel>> allStreamOrders = {};
    return _docRef.snapshots().map((event) => event.data());
  }

  Future<bool> updateRobotArrivedAtCustomer({required int robot}) async {
    bool cleaning = false;
    numOfTables = 3;
    for (int table = 1; table < numOfTables + 1; table++) {
      print(table.toString());
      bool needUpdate = false;
      bool skip = false;
      var tempId = await _docRef
          .collection('table' + table.toString())
          .where('closed', isEqualTo: false)
          .limit(1)
          .get(
            GetOptions(source: Source.serverAndCache),
          )
          .then((value) => value.docs.first.id)
          .catchError((error) {
        skip = true;
      });
      if (!skip) {
        var tempOrderJson = await _docRef
            .collection('table' + table.toString())
            .where('closed', isEqualTo: false)
            // .limit(1)
            .get(
              GetOptions(source: Source.serverAndCache),
            )
            .then((value) => value.docs.map((e) => e.data()));
        print('table: ' +
            table.toString() +
            ' ' +
            tempOrderJson.first.toString());
        var tempOrder = OrderModel.fromJson(tempOrderJson.first);
        for (var element in tempOrder.items) {
          if (element.status == 'Delivering' && element.robot == robot) {
            //came at customer with orders
            element.status = 'Arrived';
            needUpdate = true;
            // print(tempOrder.toJson());
          } else if (element.status == 'Send back') {
            //came at customers to take back meals
            element.status = 'Take back';
            element.robot = robot;
            needUpdate = true;
            // print(tempOrder.toJson());
          } else if (element.status == 'Taking back' &&
              element.robot == robot) {
            //came at owners with dirty dishes
            element.status = 'Arrived back';
            needUpdate = true;
            cleaning = true;
          } else {}

          if (needUpdate) {
            await _docRef
                .collection('table' + table.toString())
                .doc(tempId)
                .update(tempOrder.toJson());
          }
        }
      }
    }
    return cleaning;
  }

  Future<void> updateRobotArrivedWithCleaningAtOwner(
      {required int robot}) async {
    numOfTables = 3;
    for (int table = 1; table < numOfTables + 1; table++) {
      print(table.toString());
      bool needUpdate = false;
      bool skip = false;
      var tempId = await _docRef
          .collection('table' + table.toString())
          .where('closed', isEqualTo: false)
          .limit(1)
          .get(
            GetOptions(source: Source.serverAndCache),
          )
          .then((value) => value.docs.first.id)
          .catchError((error) {
        skip = true;
      });
      if (!skip) {
        var tempOrderJson = await _docRef
            .collection('table' + table.toString())
            .where('closed', isEqualTo: false)
            // .limit(1)
            .get(
              GetOptions(source: Source.serverAndCache),
            )
            .then((value) => value.docs.map((e) => e.data()));
        print('table: ' +
            table.toString() +
            ' ' +
            tempOrderJson.first.toString());
        var tempOrder = OrderModel.fromJson(tempOrderJson.first);
        for (var element in tempOrder.items) {
          if (element.status == 'Arrived back' && element.robot == robot) {
            //came at customer with orders
            element.status = 'Taken back';
            element.robot = null;
            needUpdate = true;
            // print(tempOrder.toJson());
          }
        }

        if (needUpdate) {
          await _docRef
              .collection('table' + table.toString())
              .doc(tempId)
              .update(tempOrder.toJson());
        }
      }
    }
  }

  Future<void> updateItemTrayAndRobot(
      {required int table,
      required DateTime time,
      required int tray,
      required int robot}) async {
    var tempId = await _docRef
        .collection('table' + table.toString())
        .where('closed', isEqualTo: false)
        .limit(1)
        .get(
          GetOptions(source: Source.serverAndCache),
        )
        .then((value) => value.docs.first.id);
    var doc =
        await _docRef.collection('table' + table.toString()).doc(tempId).get(
              GetOptions(source: Source.serverAndCache),
            );
    var tempOrder = OrderModel.fromJson(doc.data()!);
    for (var item in tempOrder.items) {
      if (item.time == time &&
          item.tray == null &&
          item.status == 'Ready' &&
          item.robot == null) {
        item.tray = tray;
        item.robot = robot;
        item.status = 'Delivering';
        break;
      }
    }
    _docRef
        .collection('table' + table.toString())
        .doc(tempId)
        .update(tempOrder.toJson());
  }

  Future<void> updateOrder(OrderModel order, int table) async {
    var tempId = await _docRef
        .collection('table' + table.toString())
        .where('closed', isEqualTo: false)
        .limit(1)
        .get(
          GetOptions(source: Source.serverAndCache),
        )
        .then((value) => value.docs.first.id);

    await _docRef
        .collection('table' + table.toString())
        .doc(tempId)
        .update(order.toJson());
  }

  Future<Map<dynamic, OrderModel?>> getAllCurrentOrders() async {
    numOfTables =
        await _docRef.get().then((value) => (value['tableCount'])) as int;

    for (var table = 1; table < numOfTables + 1; table++) {
      var tempOrder = await _docRef
          .collection('table' + table.toString())
          .where('closed', isEqualTo: false)
          .limit(1)
          .get(
            GetOptions(source: Source.serverAndCache),
          )
          .then((value) => value.docs.map((e) => e.data()));
      if (tempOrder.isNotEmpty) {
        allCurrentOrders[table] = OrderModel.fromJson(tempOrder.first);
      } else {
        allCurrentOrders[table] = null;
      }
    }
    return allCurrentOrders;
  }
}
