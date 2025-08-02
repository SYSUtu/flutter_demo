import 'package:flutter/material.dart';
import 'dart:async';

class TaskPage extends StatefulWidget{
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<TaskPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('自律分：$_counter'),
      ),
      body: ScrollableListWithDialog(),
    );
  }
}

class ScrollableListWithDialog extends StatelessWidget {
  const ScrollableListWithDialog({super.key});

  // 模拟列表数据
  static const List<String> items = [
    "工作日睡眠时间超过7h",
    "参加一次舞蹈训练",
    "进行一次超过30min的运动",
    "喝够1L以上的水",
    "刷小红书、抖音等app不超过1h",
    "按时完成三餐",
    "做一顿至少2人份的饭菜",
  ];

  // 显示弹窗的方法
  void _showDialog(BuildContext context, String itemText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('今天完成了这个目标吗？'),
        content: Text(
          '$itemText',
          style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
          textAlign: TextAlign.center, ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 关闭弹窗
            child: const Text('完成了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MidnightCountdownWidget(),
      ),
      // 可滑动列表
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Card(
            // 列表项样式
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(
                items[index],
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              // 点击事件 - 显示弹窗
              onTap: () => _showDialog(context, items[index]),
            ),
          );
        },
      ),
    );
  }
}

// 1. 轻量级时间显示组件（仅负责显示时间，无Scaffold）


class MidnightCountdownWidget extends StatefulWidget {
  const MidnightCountdownWidget({super.key});

  @override
  State<MidnightCountdownWidget> createState() => _MidnightCountdownWidgetState();
}

class _MidnightCountdownWidgetState extends State<MidnightCountdownWidget> {
  // 存储倒计时的剩余时间
  Duration _remainingTime = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // 初始化剩余时间
    _calculateRemainingTime();
    // 每秒更新一次
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
  }

  // 计算距离次日0点的剩余时间
  void _calculateRemainingTime() {
    final now = DateTime.now();
    // 计算今天24点（即明天0点）的时间
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    // 计算时间差
    final remaining = tomorrow.difference(now);

    setState(() {
      _remainingTime = remaining;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 格式化剩余时间为 时:分:秒
    final hours = _remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    int _flag = 1;

    return Text(
      '今日次数：$_flag，距离下一次刷新还有: $hours:$minutes:$seconds',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}