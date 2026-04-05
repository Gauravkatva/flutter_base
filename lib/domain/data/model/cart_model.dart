class CartModel {
  const CartModel({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.discountAmount = 0,
  });

  final String name;
  final int price;
  final int quantity;
  final double discountAmount;

  int get totalPrice => price * quantity;

  double get discountedPrice => totalPrice - discountAmount;

  CartModel updateQuantity(int newQuantity) {
    return CartModel(
      name: name,
      price: price,
      quantity: newQuantity,
      discountAmount: discountAmount,
    );
  }

  CartModel applyDiscount(double discount) {
    return CartModel(
      name: name,
      price: price,
      quantity: quantity,
      discountAmount: discount,
    );
  }
}
