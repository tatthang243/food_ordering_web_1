import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_ordering_web_1/model/order_model.dart';

class NewDocRepository {
  NewDocRepository({
    required this.isLogin,
    required this.table,
    required this.restaurantId,
  });

  bool isLogin;
  int table;
  String restaurantId;

  late final _docRef = FirebaseFirestore.instance
      .collection('Main')
      .doc(restaurantId)
      .collection('table' + table.toString());
  // .doc(id);
  Future<String> getOpenOrderId() async {
    return _docRef
        .where('closed', isEqualTo: false)
        .limit(1)
        .get()
        .then((value) => value.docs.first.id)
        .onError((error, stackTrace) => '');
  }

  Future<bool> createNewDoc(String id) async {
    final initData = {'closed': false, 'Items': []};
    return _docRef.doc(id).get().then((doc) {
      if (doc.exists) {
        return false;
      } else {
        return _docRef
            .doc(id)
            .set(initData)
            .then((value) => true)
            .onError((error, stackTrace) => false);
      }
    });
  }
}
