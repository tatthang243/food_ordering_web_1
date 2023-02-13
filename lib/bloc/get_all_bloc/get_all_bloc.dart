import 'package:bloc/bloc.dart';
import 'package:food_ordering_web_1/repo/admin_repo.dart';
import 'package:meta/meta.dart';

import '../../model/order_model.dart';

part 'get_all_event.dart';
part 'get_all_state.dart';

class GetAllBlocBloc extends Bloc<GetAllBlocEvent, GetAllBlocState> {
  String restaurantId;
  GetAllBlocBloc({required this.restaurantId}) : super(GetAllBlocInitial()) {
    on<GetAllBlocEvent>((event, emit) async {
      // TODO: implement event handler
      emit(GetAllBlocLoading());
      try {
        var allOrders = await AdminRepository(restaurantId: restaurantId)
            .getAllCurrentOrders();
        emit(GetAllBlocSuccess(allOrders));
      } catch (e) {
        emit(GetAllBlocFail(e.toString()));
      }
    });
  }
}
