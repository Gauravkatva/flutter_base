import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_appp/domain/data/model/cart_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

const supportedCoupon = ['SAVE100'];

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<InitialCartEvent>(_initiateCartMockData);
    on<AddItem>(_addItem);
    on<RemoveItem>(_removeItem);
    on<ApplyCoupon>(_applyCoupon);
  }

  FutureOr<void> _initiateCartMockData(
    InitialCartEvent event,
    Emitter<CartState> emit,
  ) {
    const cartItems = [
      CartModel(name: 'Apple', price: 120),
      CartModel(name: 'Banana', price: 30),
      CartModel(name: 'Milk', price: 80),
      CartModel(name: 'Bread', price: 50),
    ];

    emit(const CartState(cartItems: cartItems));
  }

  FutureOr<void> _addItem(AddItem event, Emitter<CartState> emit) {
    final currentItems = List<CartModel>.from(state.cartItems);
    final itemIndex = currentItems.indexWhere(
      (item) => item.name == event.name,
    );
    final item = currentItems.firstWhere((item) => event.name == item.name);
    final olderQuantity = item.quantity;
    final udpatedQuantity = olderQuantity + 1;
    final updatedItem = item.updateQuantity(udpatedQuantity);
    currentItems[itemIndex] = updatedItem;
    emit(state.copyWith(cartItems: currentItems));
  }

  FutureOr<void> _removeItem(RemoveItem event, Emitter<CartState> emit) async {
    final currentItems = List<CartModel>.from(state.cartItems);
    final itemIndex = currentItems.indexWhere(
      (item) => item.name == event.name,
    );
    final item = currentItems.firstWhere((item) => event.name == item.name);
    final olderQuantity = item.quantity;
    final udpatedQuantity = olderQuantity - 1;

    if (udpatedQuantity == 0) {
      currentItems.removeAt(itemIndex);
      emit(state.copyWith(cartItems: currentItems));
      return;
    }

    final updatedItem = item.updateQuantity(udpatedQuantity);
    currentItems[itemIndex] = updatedItem;
    emit(state.copyWith(cartItems: currentItems));
  }

  FutureOr<void> _applyCoupon(
    ApplyCoupon event,
    Emitter<CartState> emit,
  ) async {
    if (!supportedCoupon.contains(event.couponCode) || state.subtotal < 300) {
      emit(state.copyWith(isInavalidCoupon: true));
      return;
    }

    // Apply SAVE100 coupon logic
    const discountAmount = 100.0;
    final subtotal = state.subtotal;
    final currentItems = List<CartModel>.from(state.cartItems);

    // Distribute discount proportionally across items
    final updatedItems = currentItems.map((item) {
      final itemTotal = item.totalPrice;
      final proportionalDiscount = (itemTotal / subtotal) * discountAmount;

      // Ensure item total doesn't become negative
      final finalDiscount = proportionalDiscount > itemTotal
          ? itemTotal.toDouble()
          : proportionalDiscount;

      return item.applyDiscount(finalDiscount);
    }).toList();

    emit(state.copyWith(
      couponCode: event.couponCode,
      cartItems: updatedItems,
      isInavalidCoupon: false,
    ));
  }
}
