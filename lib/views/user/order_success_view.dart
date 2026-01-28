import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_nav_controller.dart';

class OrderSuccessView extends StatefulWidget {
  final String orderId;
  final double total;
  final int itemCount;
  final String payment;
  final String address;
  final String deliveryEta;

  const OrderSuccessView({
    super.key,
    required this.orderId,
    required this.total,
    required this.itemCount,
    required this.payment,
    required this.address,
    required this.deliveryEta,
  });

  @override
  State<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<OrderSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiCtrl;
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // ⏹ Stop + fade confetti smoothly
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _confettiCtrl.stop();
      setState(() => _showConfetti = false);
    });

    // 🔁 Redirect to Orders tab
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Get.offAllNamed("/user-root");
      Future.delayed(const Duration(milliseconds: 150), () {
        if (Get.isRegistered<UserNavController>()) {
          Get.find<UserNavController>().goToOrders();
        }
      });
    });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 🎊 CONFETTI WITH FADE OUT
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _showConfetti ? 1 : 0,
              duration: const Duration(milliseconds: 700),
              child: AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(
                    _confettiCtrl.value,
                    cs,
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ SUCCESS ICON
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 22,
                            color: cs.primary.withOpacity(0.45),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Order Confirmed",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Thank you for shopping with us",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _summaryCard(theme),

                    const SizedBox(height: 16),

                    Text(
                      "Redirecting to Orders…",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY CARD =================

  Widget _summaryCard(ThemeData theme) {
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.45 : 0.06,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row("Order ID", widget.orderId, theme),
          _row("Items", "${widget.itemCount}", theme),
          _row("Payment", widget.payment, theme),
          _row("Delivery", widget.deliveryEta, theme),
          _row(
            "Total",
            "₹${widget.total.toStringAsFixed(2)}",
            theme,
            highlight: true,
          ),
          const Divider(height: 24),
          Text(
            "Delivery Address",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.address,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value,
    ThemeData theme, {
    bool highlight = false,
  }) {
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: highlight ? cs.primary : cs.onSurface,
              fontSize: highlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================
// 🎊 CONFETTI — REDUCED + SMOOTH
// ===================================================

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final ColorScheme scheme;
  final Random random = Random();

  _ConfettiPainter(this.progress, this.scheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final colors = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.primaryContainer,
    ];

    for (int i = 0; i < 20; i++) {
      paint.color = colors[i % colors.length].withOpacity(0.55);

      final dx = random.nextDouble() * size.width;
      final dy = (progress * size.height * 0.6 + random.nextDouble() * 80) %
          size.height;

      canvas.drawCircle(
        Offset(dx, dy),
        3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
