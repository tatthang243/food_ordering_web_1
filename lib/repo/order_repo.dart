import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_ordering_web_1/model/order_model.dart';

class OrderRepository {
  OrderRepository(
      {required this.isLogin,
      required this.table,
      required this.restaurantId,
      required this.id});

  bool isLogin;
  int table;
  String restaurantId;
  String id;
  late OrderModel data;

  late final _docRef = FirebaseFirestore.instance
      .collection('Main')
      .doc(restaurantId)
      .collection('table' + table.toString())
      .doc(id);
  Future<OrderModel> getFromFirebase() async {
    var doc = await _docRef.get(
      GetOptions(source: Source.serverAndCache),
    );
    // print(doc.data());
    data = OrderModel.fromJson(doc.data()!);
    print(data.items[0].meal);
    return data;
  }

  Future<void> updateOrder({required OrderModel order}) async {
    return _docRef.update(order.toJson());
  }

  Future<void> addOrder({required Item item}) async {
    var doc = await _docRef.get(
      GetOptions(source: Source.serverAndCache),
    );
    // print(doc.data());
    data = OrderModel.fromJson(doc.data()!);
    data.items.add(item);
    for (var element in data.items) {
      print(element.meal);
    }
    _docRef.update(data.toJson());
  }

  Future<bool> createNewDoc() async {
    final initData = {'closed': false, 'Items': []};
    return _docRef
        .set(initData)
        .then((value) => true)
        .onError((error, stackTrace) => false);
  }
}
