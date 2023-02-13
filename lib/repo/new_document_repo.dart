import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_ordering_web_1/model/order_model.dart';

class NewDocRepository {
  NewDocRepository(
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

  Future<bool> createNewDoc() async {
    final initData = {'closed': false, 'Items': []};
    return _docRef.get().then((doc) {
      if (doc.exists) {
        return false;
      } else {
        return _docRef
            .set(initData)
            .then((value) => true)
            .onError((error, stackTrace) => false);
      }
    });
  }
}
