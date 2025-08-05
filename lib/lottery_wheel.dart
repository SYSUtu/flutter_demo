import 'package:flutter/material.dart';
import 'dart:math';

class LotteryWheel extends StatefulWidget {
  final double maxSize;
  final List<LotteryItem> items;

  const LotteryWheel({
    super.key,
    required this.maxSize,
    required this.items,
  });

  @override
  State<LotteryWheel> createState() => _LotteryWheelState();
}

class _LotteryWheelState extends State<LotteryWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animation;

  double _currentAngle = 0;
  bool _isSpinning = false;
  int? _currentWinningIndex;
  final List<double> _sectorAngles = [];
  final List<double> _sectorStartAngles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _calculateSectorAngles();
  }

  @override
  void didUpdateWidget(covariant LotteryWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.items, oldWidget.items)) {
      _calculateSectorAngles();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculateSectorAngles() {
    _sectorAngles.clear();
    _sectorStartAngles.clear();

    final itemCount = widget.items.length;
    final equalAngle = 360.0 / itemCount;

    double currentStartAngle = 0;
    for (int i = 0; i < itemCount; i++) {
      _sectorAngles.add(equalAngle);
      _sectorStartAngles.add(currentStartAngle);
      currentStartAngle += equalAngle;
    }
  }

  void _animationListener() {
    if (_animation != null) {
      setState(() => _currentAngle = _animation!.value);
    }
  }

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _isSpinning = false);
      if (_currentWinningIndex != null) {
        _showResult(_currentWinningIndex!);
      }
      _controller.reset();
      _currentWinningIndex = null;
    }
  }

  int _getRandomWinningIndex() {
    final totalProbability = widget.items.fold(0.0, (sum, item) => sum + item.probability);
    final randomValue = Random().nextDouble() * totalProbability;

    double cumulative = 0.0;
    for (int i = 0; i < widget.items.length; i++) {
      cumulative += widget.items[i].probability;
      if (randomValue <= cumulative) {
        return i;
      }
    }
    return widget.items.length - 1;
  }

  int _getCurrentPointedIndex() {
    final normalizedAngle = (_currentAngle % 360 + 360) % 360;

    for (int i = 0; i < _sectorStartAngles.length; i++) {
      final start = _sectorStartAngles[i];
      final end = start + _sectorAngles[i];

      if (start <= end) {
        if (normalizedAngle >= start && normalizedAngle < end) {
          return i;
        }
      } else {
        if (normalizedAngle >= start || normalizedAngle < end) {
          return i;
        }
      }
    }
    return 0;
  }

  void _startSpin() {
    if (_isSpinning) return;

    setState(() => _isSpinning = true);

    final winningIndex = _getRandomWinningIndex();
    _currentWinningIndex = winningIndex;

    _animation?.removeListener(_animationListener);
    _animation?.removeStatusListener(_statusListener);

    final startAngle = _sectorStartAngles[winningIndex];
    final endAngle = startAngle + _sectorAngles[winningIndex];
    final randomInRange = startAngle + Random().nextDouble() * (endAngle - startAngle);
    final targetAngle = _currentAngle + 360 * 3 + randomInRange;

    _animation = Tween<double>(begin: _currentAngle, end: targetAngle).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.2, 0.8, 0.2, 1.0),
      ),
    )..addListener(_animationListener)
      ..addStatusListener(_statusListener);

    _controller.forward(from: 0.0);
  }

  void _showResult(int winningIndex) {
    final actualIndex = _getCurrentPointedIndex();
    debugPrint("预期中奖索引：$winningIndex，实际指向索引：$actualIndex");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("抽奖结果"),
        content: Text("恭喜您获得：${widget.items[winningIndex].name}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("确定"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wheelSize = widget.maxSize;

    if (_sectorAngles.isEmpty || _sectorAngles.length != widget.items.length) {
      _calculateSectorAngles();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.arrow_downward,
          color: Colors.red,
          size: 36,
          shadows: [Shadow(color: Colors.black38, blurRadius: 2)],
        ),
        Container(
          width: wheelSize,
          height: wheelSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipOval(
            child: _buildWheelContent(wheelSize),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: min(200, wheelSize * 0.8),
          child: ElevatedButton(
            onPressed: _isSpinning ? null : _startSpin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _isSpinning ? "转动中..." : "开始抽奖",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWheelContent(double size) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Transform.rotate(
        // 转盘整体旋转角度（弧度）
        angle: _currentAngle * pi / 180,
        child: Stack(
          children: [
            ...List.generate(widget.items.length, (index) {
              final startAngleRad = _sectorStartAngles[index] * pi / 180;
              final sweepAngleRad = _sectorAngles[index] * pi / 180;
              // 扇区中心角度（弧度）
              final centerAngleRad = startAngleRad + sweepAngleRad / 2;
              // 转盘当前旋转角度（弧度）
              final currentAngleRad = _currentAngle * pi / 180;

              // 文字和图标尺寸（根据转盘大小动态调整）
              final textSize = max(size * 0.045, 14.0);
              final iconSize = max(size * 0.07, 18.0);

              // 计算文字旋转角度：
              // 1. 抵消转盘整体旋转（-currentAngleRad）
              // 2. 抵消扇区自身角度（-centerAngleRad）
              // 3. 最终加pi/2确保文字垂直向上
              final textRotation = -currentAngleRad - centerAngleRad + pi / 2;

              return ClipPath(
                clipper: _WheelClipper(startAngleRad, sweepAngleRad),
                child: Container(
                  color: widget.items[index].color,
                  child: Stack(
                    children: [
                      // 极坐标定位：精准居中于扇区
                      Positioned(
                        // 核心公式：计算扇区中心的坐标
                        left: size / 2 + (size * 0.35) * cos(centerAngleRad),
                        top: size / 2 + (size * 0.35) * sin(centerAngleRad),
                        // 强制文字块居中对齐
                        child: Transform.rotate(
                          angle: textRotation,
                          child: Container(
                            // 固定文字块宽度，避免换行导致的歪斜
                            width: textSize * 5, // 根据最长文字调整
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.items[index].icon,
                                  color: Colors.white,
                                  size: iconSize,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.items[index].name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: textSize,
                                    height: 1.0, // 消除文字行高导致的偏移
                                  ),
                                  softWrap: false,
                                  overflow: TextOverflow.visible,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            // 转盘中心
            Center(
              child: CircleAvatar(
                radius: size * 0.1,
                backgroundColor: Colors.white,
                child: Icon(Icons.circle, color: Colors.red, size: size * 0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

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
  }) : assert(probability > 0, "概率必须大于0");
}

class _WheelClipper extends CustomClipper<Path> {
  final double startAngle;
  final double sweepAngle;

  _WheelClipper(this.startAngle, this.sweepAngle);

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _WheelClipper oldClipper) {
    return oldClipper.startAngle != startAngle || oldClipper.sweepAngle != sweepAngle;
  }
}

// 辅助方法：比较两个列表是否相等
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}