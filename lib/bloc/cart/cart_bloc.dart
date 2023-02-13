import 'package:bloc/bloc.dart';
import 'package:food_ordering_web_1/model/order_model.dart';
import 'package:food_ordering_web_1/repo/order_repo.dart';
import 'package:meta/meta.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  bool isLogin;
  int table;
  String restaurantId;
  String id;

  CartBloc(
      {required this.isLogin,
      required this.table,
      required this.restaurantId,
      required this.id})
      : super(CartInitial()) {
    on<CartEvent>((event, emit) async {
      // TODO: implement event handler
      emit(CartLoading());
      try {
        var orders = await OrderRepository(
                id: id,
                isLogin: isLogin,
                table: table,
                restaurantId: restaurantId)
            .getFromFirebase();
        emit(CartSuccess(orders));
      } catch (e) {
        emit(CartFail(e.toString()));
      }
    });
  }
}
