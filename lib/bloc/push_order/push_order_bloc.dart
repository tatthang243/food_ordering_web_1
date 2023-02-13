import 'package:bloc/bloc.dart';
import 'package:food_ordering_web_1/model/order_model.dart';
import 'package:food_ordering_web_1/repo/order_repo.dart';
import 'package:meta/meta.dart';

part 'push_order_event.dart';
part 'push_order_state.dart';

class PushOrderBloc extends Bloc<PushOrderEvent, PushOrderState> {
  bool isLogin;
  int table;
  String restaurantId;
  String id;
  OrderModel order;
  PushOrderBloc(
      {required this.isLogin,
      required this.table,
      required this.restaurantId,
      required this.id,
      required this.order})
      : super(PushOrderInitial()) {
    on<PushOrderEvent>((event, emit) {
      // TODO: implement event handler
      emit(PushOrderLoading());
      try {
        OrderRepository(
                isLogin: isLogin,
                table: table,
                restaurantId: restaurantId,
                id: id)
            .updateOrder(order: order);
      } catch (e) {
        emit(PushOrderFail(e.toString()));
      }
    });
  }
}
