part of 'cart_bloc.dart';

class CartState extends Equatable {
  const CartState({
    this.cartItems = const [],
    this.couponCode,
    this.isInavalidCoupon = false,
  });
  final List<CartModel> cartItems;
  final String? couponCode;
  final bool isInavalidCoupon;

  int get subtotal {
    var result = 0;
    for (final item in cartItems) {
      result += item.totalPrice;
    }
    return result;
  }

  double get discountedSubtotal {
    var result = 0.0;
    for (final item in cartItems) {
      result += item.discountedPrice;
    }
    return result;
  }

  double get totalDiscount {
    return subtotal - discountedSubtotal;
  }

  double get tax {
    return discountedSubtotal * 0.10;
  }

  double get finalTotal {
    return discountedSubtotal + tax;
  }

  @override
  List<Object?> get props => [cartItems, couponCode, isInavalidCoupon];

  CartState copyWith({
    List<CartModel>? cartItems,
    String? couponCode,
    bool? isInavalidCoupon,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      couponCode: couponCode ?? this.couponCode,
      isInavalidCoupon: isInavalidCoupon ?? this.isInavalidCoupon,
    );
  }
}
