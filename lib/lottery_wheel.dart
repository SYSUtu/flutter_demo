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
  final int currentCounter;
  final Function(int) onCounterUpdated;

  const LotteryWheel({
    super.key,
    required this.maxSize,
    required this.items,
    required this.currentCounter,
    required this.onCounterUpdated
  });

  @override
  _LotteryWheelState createState() => _LotteryWheelState();
}

class _LotteryWheelState extends State<LotteryWheel>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _currentAngle = 0.0;
  bool _isSpinning = false;
  late int _selectedIndex;
  late AnimationController _resetController;
  Animation<double>? _resetAnimation;

  static const Duration _spinDuration = Duration(seconds: 6);
  static const Duration _resetDuration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _spinDuration);
    _resetController = AnimationController(vsync: this, duration: _resetDuration);

    _controller.addListener(() => setState(() => _currentAngle = _rotationAnimation.value));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isSpinning = false);
        // 添加延迟确保动画完全结束
        Future.delayed(const Duration(milliseconds: 200), _showResultDialog);
      }
    });

    _resetController.addListener(() {
      if (_resetAnimation != null) setState(() => _currentAngle = _resetAnimation!.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;
    _isSpinning = true;

    // 1. 验证概率总和（不变）
    final totalProbability = widget.items.fold(0.0, (sum, item) => sum + item.probability);
    assert((totalProbability - 100.0).abs() < 0.001,
    '概率总和必须为100%，当前: $totalProbability%');

    // 2. 随机确定中奖奖项（不变）
    final random = Random();
    final double randomValue = random.nextDouble() * totalProbability;

    double cumulative = 0;
    for (int i = 0; i < widget.items.length; i++) {
      cumulative += widget.items[i].probability;
      if (randomValue <= cumulative) {
        _selectedIndex = i;
        break;
      }
    }

    // 3. 计算角度参数（不变）
    final int itemCount = widget.items.length;
    final double anglePerItem = 2 * pi / itemCount;

    // 4. 计算中奖区域中心角度（不变）
    final double sectorCenterAngle = -pi/2 + (_selectedIndex * anglePerItem) + (anglePerItem / 2);

    // 5. 随机停留偏移（不变）
    final double offsetRange = 0.3;
    final double randomOffset = (random.nextDouble() * 2 * offsetRange) - offsetRange;
    final double finalStopAngle = sectorCenterAngle + (randomOffset * anglePerItem);

    // 6. 计算目标旋转角度（修正符号）
    final double pointerOffset = pi/2; // 90度指针补偿
    final double targetAngle = _currentAngle +
        10 * 2 * pi -
        finalStopAngle -  // 关键修正：将+改为-
        pointerOffset;

    // 7. 执行动画（不变）
    _rotationAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: _currentAngle, end: _currentAngle + 5 * 2 * pi)
            .chain(CurveTween(curve: Curves.easeInOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _currentAngle + 5 * 2 * pi, end: targetAngle)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
    ]).animate(_controller);

    _controller.forward(from: 0);
  }

  void _resetWheel() {
    if (_resetController.isAnimating) _resetController.stop();

    // 角度归一化到 [0, 2π)
    final double normalizedAngle = _currentAngle % (2 * pi);

    // 计算最短路径回归初始位置
    double resetAngle;
    if (normalizedAngle > pi) {
      resetAngle = normalizedAngle - 2 * pi;
    } else {
      resetAngle = normalizedAngle;
    }

    _resetAnimation = Tween<double>(
        begin: _currentAngle,
        end: _currentAngle - resetAngle
    ).animate(CurvedAnimation(
        parent: _resetController,
        curve: Curves.easeInOut
    ));

    _resetController.forward(from: 0);
  }

  void _showResultDialog() {
    // 从抽中奖项的名称中提取分数值
    int scoreToAdd = 0;
    final prizeName = widget.items[_selectedIndex].name;

    // 处理加分的情况（如 "+2积分"、"+10积分"）
    if (prizeName.startsWith('+')) {
      // 提取数字部分
      final scoreStr = prizeName.replaceAll(RegExp(r'[^\d]'), '');
      if (scoreStr.isNotEmpty) {
        scoreToAdd = int.parse(scoreStr);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "抽奖结果",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Icon(
                widget.items[_selectedIndex].icon,
                color: widget.items[_selectedIndex].color,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                "您抽中了：${widget.items[_selectedIndex].name}",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              // 显示加分信息（如果中奖）
              if (scoreToAdd > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "已为您增加 $scoreToAdd 积分",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // 更新计数器：当前分数 + 抽中分数
                  if (scoreToAdd > 0) {
                    widget.onCounterUpdated(widget.currentCounter + scoreToAdd);
                  }
                  _resetWheel();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text("确定", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
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
            // 精确指针定位
            const Positioned(
              top: -4, // 微调指针位置
              child: _WheelPointer(),
            ),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: (){
            if (!_isSpinning) {
              // 如果正在旋转，回调为 null（按钮禁用）
              widget.onCounterUpdated(widget.currentCounter-1);
              _spinWheel();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSpinning ? Colors.grey[400] : Colors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _isSpinning ? '转动中...' : '开始抽奖(-1分)',
            style: TextStyle(
              color: _isSpinning ? Colors.grey[700] : Colors.white,
            ),
          ),
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
    final double anglePerItem = 2 * pi / itemCount;

    // 从顶部开始绘制（-pi/2）
    double startAngle = -pi / 2;
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: max(14, radius * 0.09), // 动态字体大小
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black54,
          offset: Offset(1, 1),
        ),
      ],
    );

    // 绘制扇形和文字
    for (int i = 0; i < itemCount; i++) {
      final item = items[i];

      // 绘制扇形
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerItem,
        true,
        paint,
      );

      // 绘制分割线
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(startAngle) * radius,
          center.dy + sin(startAngle) * radius,
        ),
        linePaint,
      );

      // 计算文字位置（扇形中心）
      final textAngle = startAngle + anglePerItem / 2;
      final textRadius = radius * 0.65; // 文字离中心距离
      final textOffset = Offset(
        center.dx + cos(textAngle) * textRadius,
        center.dy + sin(textAngle) * textRadius,
      );

      // 绘制文字
      final textPainter = TextPainter(
        text: TextSpan(text: item.name, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(textAngle + pi / 2); // 文字径向排列
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();

      startAngle += anglePerItem;
    }

    // 中心圆（带阴影）
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WheelPointer extends StatelessWidget {
  const _WheelPointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(36, 48), // 加大指针尺寸
      painter: _PointerPainter(),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0) // 指针尖端
      ..lineTo(size.width * 0.15, size.height * 0.9) // 左侧点
      ..lineTo(size.width * 0.85, size.height * 0.9) // 右侧点
      ..close();

    // 填充指针
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.fill,
    );

    // 指针边框
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.red[900]!
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // 中心标记点（精确定位）
    canvas.drawCircle(
      Offset(size.width / 2, 0),
      3.5,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}