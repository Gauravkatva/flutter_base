part of 'cart_bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class InitialCartEvent extends CartEvent {}

class AddItem extends CartEvent {
  const AddItem({required this.name});

  final String name;
}

class RemoveItem extends CartEvent {
  const RemoveItem({required this.name});

  final String name;
}

class ApplyCoupon extends CartEvent {
  const ApplyCoupon({required this.couponCode});

  final String couponCode;
}
