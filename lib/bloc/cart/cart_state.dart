part of 'cart_bloc.dart';

@immutable
abstract class CartState {}

class CartInitial extends CartState {
  @override
  List<Object> get props => [];
}

class CartLoading extends CartState {
  @override
  List<Object> get props => [];
}

class CartSuccess extends CartState {
  CartSuccess(this.orders);
  final OrderModel orders;
  @override
  List<Object> get props => [orders];
}

class CartFail extends CartState {
  CartFail(this.message);
  final String message;
  @override
  List<Object> get props => [message];
}
