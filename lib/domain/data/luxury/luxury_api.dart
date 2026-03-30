import 'dart:math';

class LuxuryApi {
  LuxuryApi(this._random);
  final Random _random;

  Stream<Map<String, dynamic>> getLuxuryItems() async* {
    // on every 800 milisecond it should emits the data in stock and price
    var initialStock = 1000;
    var initialPrice = 1000;
    while (initialStock >= 0) {
      initialStock = initialStock - _random.nextInt(100);
      initialPrice = initialPrice + _random.nextInt(100);
      if (initialStock < 0) {
        initialStock = _random.nextInt(1000);
        initialPrice = _random.nextInt(1000);
        yield {'stock': initialStock, 'price': initialPrice};
      }
      yield {'stock': initialStock, 'price': initialPrice};
      await Future<void>.delayed(const Duration(milliseconds: 1500));
    }
  }
}
