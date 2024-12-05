import 'package:coffee_shop/features/user/cart/bloc/cart_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final CartItem item;

  const AddToCart(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final CartItem item;

  const RemoveFromCart(this.item);

  @override
  List<Object> get props => [item];
}
