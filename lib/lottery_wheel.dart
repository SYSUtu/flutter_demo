import 'dart:math';
import 'package:flutter/material.dart';

class LotteryItem {
  final String name;
  final Color color;
  final IconData icon;
  final double probability;

  LotteryItem({
    required this.name,
    required this.color,
    required this.icon,
    required this.probability,
  });
}

class LotteryWheel extends StatefulWidget {
  final double maxSize;
  final List<LotteryItem> items;

  const LotteryWheel({
    Key? key,
    required this.maxSize,
    required this.items,
  }) : super(key: key);

  @override
  _LotteryWheelState createState() => _LotteryWheelState();
}

class _LotteryWheelState extends State<LotteryWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _currentAngle = 0.0;
  bool _isSpinning = false;
  late int _selectedIndex;

  static const Duration _spinDuration = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _spinDuration,
    );

    _controller.addListener(() {
      setState(() {
        _currentAngle = _rotationAnimation.value;
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _showResultDialog();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;
    _isSpinning = true;

    final random = Random();
    final totalProbability = widget.items.fold(
        0.0, (sum, item) => sum + item.probability);
    final double randomValue = random.nextDouble() * totalProbability;

    double cumulative = 0;
    for (int i = 0; i < widget.items.length; i++) {
      cumulative += widget.items[i].probability;
      if (randomValue <= cumulative) {
        _selectedIndex = i;
        break;
      }
    }

    final int itemCount = widget.items.length;
    final double anglePerItem = 2 * pi / itemCount;

    final double targetAngle = _currentAngle
        + 10 * 2 * pi
        + (pi / 2)
        - (_selectedIndex * anglePerItem)
        - (anglePerItem / 2);

    _rotationAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _currentAngle,
          end: _currentAngle + 4 * 2 * pi,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _currentAngle + 4 * 2 * pi,
          end: targetAngle,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _controller.forward(from: 0);
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("恭喜中奖！"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.items[_selectedIndex].icon,
              color: widget.items[_selectedIndex].color,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              "您抽中了：${widget.items[_selectedIndex].name}",
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _currentAngle,
              child: CustomPaint(
                size: Size(widget.maxSize, widget.maxSize),
                painter: _WheelPainter(items: widget.items),
              ),
            ),
            const Positioned(
              top: -5,
              child: _WheelPointer(),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isSpinning ? null : _spinWheel,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSpinning ? Colors.grey : Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: Text(_isSpinning ? '转动中...' : '开始抽奖'),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<LotteryItem> items;

  _WheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final itemCount = items.length;
    final anglePerItem = 2 * pi / itemCount;

    double startAngle = -pi / 2;
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: radius * 0.08,
      fontWeight: FontWeight.bold,
    );

    for (final item in items) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerItem,
        true,
        Paint()..color = item.color,
      );

      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(startAngle) * radius,
          center.dy + sin(startAngle) * radius,
        ),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      final textAngle = startAngle + anglePerItem / 2;
      final textOffset = Offset(
        center.dx + cos(textAngle) * radius * 0.6,
        center.dy + sin(textAngle) * radius * 0.6,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: item.name, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();

      startAngle += anglePerItem;
    }

    canvas.drawCircle(
      center,
      radius * 0.1,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WheelPointer extends StatelessWidget {
  const _WheelPointer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 40),
      painter: _PointerPainter(),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.redAccent);
    canvas.drawCircle(Offset(size.width / 2, 0), 3, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}