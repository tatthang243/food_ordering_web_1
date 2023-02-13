part of 'get_all_bloc.dart';

@immutable
abstract class GetAllBlocState {}

class GetAllBlocInitial extends GetAllBlocState {
  @override
  List<Object> get props => [];
}

class GetAllBlocLoading extends GetAllBlocState {
  @override
  List<Object> get props => [];
}

class GetAllBlocSuccess extends GetAllBlocState {
  GetAllBlocSuccess(this.allOrders);
  final Map<dynamic, dynamic> allOrders;
  @override
  List<Object> get props => [allOrders];
}

class GetAllBlocFail extends GetAllBlocState {
  GetAllBlocFail(this.message);
  final String message;
  @override
  List<Object> get props => [message];
}
