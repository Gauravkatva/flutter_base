class LuxuryModel {
  LuxuryModel({required this.stock, required this.price});
  factory LuxuryModel.fromJson(Map<String, dynamic> json) {
    return LuxuryModel(
      stock: json['stock'] as int,
      price: json['price'] as int,
    );
  }
  final int stock;
  final int price;
}
