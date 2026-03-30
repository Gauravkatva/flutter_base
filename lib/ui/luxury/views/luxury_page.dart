import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_appp/di/injection.dart';
import 'package:my_appp/domain/data/luxury/luxury_api.dart';
import 'package:my_appp/domain/data/model/luxury_model.dart';
import 'package:my_appp/ui/luxury/bloc/luxury_bloc.dart';

class LuxuryPage extends StatelessWidget {
  const LuxuryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LuxuryBloc(getIt.get<LuxuryApi>())..add(LoadLocalPricing()),
      child: const _LuxuryPageScreen(),
    );
  }
}

class _LuxuryPageScreen extends StatefulWidget {
  const _LuxuryPageScreen();

  @override
  State<_LuxuryPageScreen> createState() => __LuxuryPageScreenState();
}

class __LuxuryPageScreenState extends State<_LuxuryPageScreen> {
  double _previousPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Luxury Investments',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0A0E21),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0A0E21),
      body: BlocBuilder<LuxuryBloc, LuxuryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }

          final currentPrice =
              state.allPrices.lastOrNull?.price.toDouble() ?? 0;
          if (_previousPrice == 0) _previousPrice = currentPrice;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Price Display
                  const Text(
                    'Current Price',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(
                      begin: _previousPrice,
                      end: currentPrice,
                    ),
                    onEnd: () {
                      _previousPrice = currentPrice;
                    },
                    builder: (context, animatedPrice, child) {
                      final priceChange = animatedPrice - _previousPrice;
                      final isPositive = priceChange >= 0;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${animatedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isPositive
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPositive
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: isPositive
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  priceChange.abs().toStringAsFixed(2),
                                  style: TextStyle(
                                    color: isPositive
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Premium Stock Chart
                  const Text(
                    'Price History',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F3A),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        child: CustomPaint(
                          key: ValueKey(state.chartData.length),
                          painter: PremiumStockChartPainter(
                            state.chartData,
                          ),
                          child: Container(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Hold to Secure Button
                  Center(
                    child: HoldToSecureButton(
                      onPurchaseComplete: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Purchase Secured Successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PremiumStockChartPainter extends CustomPainter {
  PremiumStockChartPainter(this.priceList);
  final List<LuxuryModel> priceList;

  @override
  void paint(Canvas canvas, Size size) {
    if (priceList.isEmpty || size.width <= 0 || size.height <= 0) return;

    const padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // Find min and max prices for scaling
    final prices = priceList.map((e) => e.price.toDouble()).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = maxPrice - minPrice;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (var i = 0; i <= 5; i++) {
      final y = padding + (chartHeight / 5) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Calculate x position for each point
    double getXPosition(int index) {
      if (priceList.length == 1) {
        return size.width / 2;
      }
      return padding + (index * chartWidth / (priceList.length - 1));
    }

    // Draw gradient fill under the line
    final gradientPath = Path();
    gradientPath.moveTo(padding, size.height - padding);

    for (var i = 0; i < priceList.length; i++) {
      final x = getXPosition(i);
      final normalizedPrice =
          (priceList[i].price - minPrice) / (priceRange > 0 ? priceRange : 1);
      final y = size.height - padding - (normalizedPrice * chartHeight);
      gradientPath.lineTo(x, y);
    }

    gradientPath.lineTo(
      priceList.length == 1 ? size.width / 2 : size.width - padding,
      size.height - padding,
    );
    gradientPath.close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6C63FF).withOpacity(0.3),
          const Color(0xFF6C63FF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(gradientPath, gradientPaint);

    // Draw the main line
    final linePath = Path();
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFF42A5F5)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < priceList.length; i++) {
      final x = getXPosition(i);
      final normalizedPrice =
          (priceList[i].price - minPrice) / (priceRange > 0 ? priceRange : 1);
      final y = size.height - padding - (normalizedPrice * chartHeight);

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;

    final pointOutlinePaint = Paint()
      ..color = const Color(0xFF1A1F3A)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < priceList.length; i++) {
      final x = getXPosition(i);
      final normalizedPrice =
          (priceList[i].price - minPrice) / (priceRange > 0 ? priceRange : 1);
      final y = size.height - padding - (normalizedPrice * chartHeight);

      canvas.drawCircle(Offset(x, y), 5, pointOutlinePaint);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }

    // Draw Y-axis labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i <= 5; i++) {
      final price = maxPrice - (priceRange / 5) * i;
      final y = padding + (chartHeight / 5) * i;

      textPainter.text = TextSpan(
        text: '\$${price.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant PremiumStockChartPainter oldDelegate) {
    return oldDelegate.priceList != priceList;
  }
}

class HoldToSecureButton extends StatefulWidget {
  const HoldToSecureButton({required this.onPurchaseComplete, super.key});

  final VoidCallback onPurchaseComplete;

  @override
  State<HoldToSecureButton> createState() => _HoldToSecureButtonState();
}

class _HoldToSecureButtonState extends State<HoldToSecureButton>
    with TickerProviderStateMixin {
  late AnimationController _holdController;
  late AnimationController _loadingController;
  late AnimationController _successController;

  ButtonState _buttonState = ButtonState.idle;

  @override
  void initState() {
    super.initState();

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _holdController.addListener(() {
      if (_holdController.value == 1.0 && _buttonState == ButtonState.holding) {
        setState(() {
          _buttonState = ButtonState.loading;
        });
        _startLoadingAnimation();
      }
    });
  }

  Future<void> _startLoadingAnimation() async {
    // Simulate loading with a delay
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _buttonState = ButtonState.success;
    });
    await _successController.forward();
    widget.onPurchaseComplete();

    // Reset after 2 seconds
    await Future<void>.delayed(const Duration(seconds: 2));
    _resetButton();
  }

  void _resetButton() {
    setState(() {
      _buttonState = ButtonState.idle;
    });
    _holdController.reset();
    _loadingController.reset();
    _successController.reset();
  }

  void _onTapDown(TapDownDetails details) {
    if (_buttonState == ButtonState.idle) {
      setState(() {
        _buttonState = ButtonState.holding;
      });
      _holdController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_buttonState == ButtonState.holding) {
      setState(() {
        _buttonState = ButtonState.idle;
      });
      _holdController.animateBack(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTapCancel() {
    if (_buttonState == ButtonState.holding) {
      setState(() {
        _buttonState = ButtonState.idle;
      });
      _holdController.animateBack(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _holdController.dispose();
    _loadingController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _holdController,
          _loadingController,
          _successController,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: HoldToSecureButtonPainter(
              progress: _holdController.value,
              loadingProgress: _loadingController.value,
              successProgress: _successController.value,
              buttonState: _buttonState,
            ),
            child: Container(
              width: 280,
              height: 64,
              alignment: Alignment.center,
              child: _buildButtonContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonContent() {
    switch (_buttonState) {
      case ButtonState.idle:
      case ButtonState.holding:
        return const Text(
          'Hold to Secure',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        );
      case ButtonState.loading:
        return const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          ),
        );
      case ButtonState.success:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 40,
              ),
            );
          },
        );
    }
  }
}

enum ButtonState { idle, holding, loading, success }

class HoldToSecureButtonPainter extends CustomPainter {
  HoldToSecureButtonPainter({
    required this.progress,
    required this.loadingProgress,
    required this.successProgress,
    required this.buttonState,
  });

  final double progress;
  final double loadingProgress;
  final double successProgress;
  final ButtonState buttonState;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2;

    // Base button
    final buttonPaint = Paint()
      ..shader = LinearGradient(
        colors: buttonState == ButtonState.success
            ? [const Color(0xFF4CAF50), const Color(0xFF45A049)]
            : [const Color(0xFF6C63FF), const Color(0xFF5A52D5)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final buttonRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawRRect(buttonRect, glowPaint);
    canvas.drawRRect(buttonRect, buttonPaint);

    // Progress ring while holding
    if (buttonState == ButtonState.holding && progress > 0) {
      final progressPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final progressRect = Rect.fromCircle(
        center: center,
        radius: radius + 8,
      );

      canvas.drawArc(
        progressRect,
        -1.5708, // Start from top (-90 degrees in radians)
        progress * 6.2832, // Full circle is 2π radians
        false,
        progressPaint,
      );
    }

    // Pulsing ring while loading
    if (buttonState == ButtonState.loading) {
      final pulseRadius = radius + 8 + (loadingProgress * 10);
      final pulsePaint = Paint()
        ..color = Colors.white.withOpacity(1 - loadingProgress)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant HoldToSecureButtonPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.loadingProgress != loadingProgress ||
        oldDelegate.successProgress != successProgress ||
        oldDelegate.buttonState != buttonState;
  }
}
