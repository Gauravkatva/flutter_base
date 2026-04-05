import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/ui/cart/bloc/cart_bloc.dart';
import 'package:my_appp/ui/cart/view/stepper_button.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc()..add(InitialCartEvent()),
      child: const _CartViewState(),
    );
  }
}

class _CartViewState extends StatefulWidget {
  const _CartViewState();

  @override
  State<_CartViewState> createState() => __CartViewStateState();
}

class __CartViewStateState extends State<_CartViewState> {
  final couponController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.cartItems.isEmpty) {
            return const Center(
              child: Text('No Cart Items Present!'),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = state.cartItems[index];
                    return Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name),
                          if (state.couponCode != null &&
                              item.discountAmount > 0)
                            Row(
                              children: [
                                Text(
                                  '₹${item.totalPrice}',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${item.discountedPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text('₹${item.totalPrice}'),
                          Row(
                            children: [
                              StepperButton(
                                icon: Icons.remove,
                                onPressed: () => context.read<CartBloc>().add(
                                  RemoveItem(name: item.name),
                                ),
                              ),
                              Text(item.quantity.toString()),
                              StepperButton(
                                icon: Icons.add,
                                onPressed: () => context.read<CartBloc>().add(
                                  AddItem(name: item.name),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: couponController,
                        decoration: const InputDecoration(
                          hintText: 'Enter coupon code',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CartBloc>().add(
                            ApplyCoupon(couponCode: couponController.text),
                          );
                        },
                        child: const Text('APPLY'),
                      ),
                      if (state.isInavalidCoupon)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Invalid coupon code or minimum amount not met',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      if (state.couponCode != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Coupon ${state.couponCode} applied!',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal:'),
                                Text('₹${state.subtotal}'),
                              ],
                            ),
                            if (state.couponCode != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Discount:',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  Text(
                                    '-₹${state.totalDiscount.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Discounted Subtotal:'),
                                  Text(
                                    '₹${state.discountedSubtotal.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tax (10%):'),
                                Text('₹${state.tax.toStringAsFixed(2)}'),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Final Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${state.finalTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }
}
