part of 'push_order_bloc.dart';

@immutable
abstract class PushOrderState {}

class PushOrderInitial extends PushOrderState {
  @override
  List<Object> get props => [];
}

class PushOrderLoading extends PushOrderState {
  @override
  List<Object> get props => [];
}

class PushOrderSuccess extends PushOrderState {
  PushOrderSuccess(this.orders);
  final OrderModel orders;
  @override
  List<Object> get props => [orders];
}

class PushOrderFail extends PushOrderState {
  PushOrderFail(this.message);
  final String message;
  @override
  List<Object> get props => [message];
}
