import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/order_model.dart';

class AdminRepository {
  AdminRepository({required this.restaurantId});
  String restaurantId;
  late int numOfTables;
  late Map<dynamic, dynamic> allCurrentOrders = {};
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
    numOfTables = 6;
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

  Future<Map<dynamic, dynamic>> getAllCurrentOrders() async {
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
