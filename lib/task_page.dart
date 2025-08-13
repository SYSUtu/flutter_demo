import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<TaskPage> {
  int _counter = 0;
  int _flag = 1; // 每日可完成次数（1次）
  DateTime _specifiedDate = DateTime(2025, 8, 6); // 基准日期（用于判断跨天）
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs(); // 初始化本地存储并检查跨天
  }

  // 初始化本地存储并读取数据
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // 读取存储的状态
    setState(() {
      _counter = _prefs.getInt('counter') ?? 0;
      _flag = _prefs.getInt('flag') ?? 1;

      // 读取_specifiedDate（时间戳转DateTime）
      final int? specifiedTimestamp = _prefs.getInt('specifiedDate');
      if (specifiedTimestamp != null) {
        _specifiedDate = DateTime.fromMillisecondsSinceEpoch(specifiedTimestamp);
      }
    });

    // 检查是否跨天，需要重置flag
    _checkAndResetForNewDay();
  }

  // 检查是否跨天，若跨天则重置flag和基准日期
  Future<void> _checkAndResetForNewDay() async {
    final DateTime now = DateTime.now();
    // 提取当前日期（忽略时分秒）
    final DateTime today = DateTime(now.year, now.month, now.day);
    // 提取存储的基准日期（忽略时分秒）
    final DateTime lastRecordDate = DateTime(
      _specifiedDate.year,
      _specifiedDate.month,
      _specifiedDate.day,
    );

    // 若当前日期比基准日期晚1天及以上，重置flag
    if (today.difference(lastRecordDate).inDays >= 1) {
      setState(() {
        _flag = 1; // 重置每日可完成次数
      });
      await _saveFlag(1);
      // 更新基准日期为今天
      _specifiedDate = today;
      await _saveSpecifiedDate(today);
    }
  }

  // 保存_counter到本地
  Future<void> _saveCounter(int value) async {
    await _prefs.setInt('counter', value);
  }

  // 保存_flag到本地
  Future<void> _saveFlag(int value) async {
    await _prefs.setInt('flag', value);
  }

  // 保存基准日期（转换为时间戳）
  Future<void> _saveSpecifiedDate(DateTime value) async {
    final int timestamp = value.millisecondsSinceEpoch;
    await _prefs.setInt('specifiedDate', timestamp);
  }

  // 更新基准日期（对外暴露的方法）
  void updateSpecifiedDate(DateTime value) {
    // 仅保留年月日（忽略时分秒）
    final DateTime dateOnly = DateTime(value.year, value.month, value.day);
    setState(() {
      _specifiedDate = dateOnly;
    });
    _saveSpecifiedDate(dateOnly);
  }

  // 更新计数器
  void updateCounter(int value) {
    setState(() {
      _counter = value;
    });
    _saveCounter(value);
  }

  // 更新每日可完成次数
  void updateFlag(int value) {
    setState(() {
      _flag = value;
    });
    _saveFlag(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('自律分：$_counter'),
      ),
      body: ScrollableListWithDialog(
        currentCounter: _counter,
        onCounterUpdated: updateCounter,
        currentFlag: _flag,
        flagUpdated: updateFlag,
        specifiedDateUpdate: updateSpecifiedDate,
      ),
    );
  }
}

class ScrollableListWithDialog extends StatelessWidget {
  final int currentCounter;
  final Function(int) onCounterUpdated;
  final int currentFlag;
  final Function(int) flagUpdated;
  final Function(DateTime) specifiedDateUpdate;

  const ScrollableListWithDialog({
    super.key,
    required this.currentCounter,
    required this.onCounterUpdated,
    required this.currentFlag,
    required this.flagUpdated,
    required this.specifiedDateUpdate,
  });

  // 任务列表数据
  static const List<String> items = [
    "工作日睡眠时间超过7h",
    "参加一次舞蹈训练",
    "进行一次超过30min的运动",
    "喝够1L以上的水",
    "刷小红书、抖音等app不超过1h",
    "按时完成三餐",
    "做一顿至少2人份的饭菜",
  ];

  // 显示完成任务的弹窗
  void _showDialog(BuildContext context, String itemText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('今天完成了这个目标吗？'),
        content: Text(
          itemText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 只有当日可完成次数为1时，才允许加分
              if (currentFlag == 1) {
                onCounterUpdated(currentCounter + 1);
                flagUpdated(0); // 用完今日次数
                specifiedDateUpdate(DateTime.now()); // 记录当前日期
              }
              Navigator.pop(context);
            },
            child: const Text('完成了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 移除嵌套Scaffold，直接返回列表内容
    return Column(
      children: [
        // 顶部倒计时标题
        AppBar(
          title: MidnightCountdownWidget(flag: currentFlag),
          elevation: 0, // 去除阴影，避免和父级AppBar冲突
          automaticallyImplyLeading: false, // 隐藏返回按钮
        ),
        // 任务列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Card(
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
                  onTap: () => _showDialog(context, items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class MidnightCountdownWidget extends StatefulWidget {
  final int flag;

  const MidnightCountdownWidget({super.key, required this.flag});

  @override
  State<MidnightCountdownWidget> createState() => _MidnightCountdownWidgetState();
}

class _MidnightCountdownWidgetState extends State<MidnightCountdownWidget> {
  Duration _remainingTime = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    // 每秒更新一次倒计时
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateRemainingTime();
    });
  }

  // 计算距离次日0点的剩余时间
  void _calculateRemainingTime() {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    final Duration remaining = tomorrow.difference(now);

    setState(() {
      _remainingTime = remaining;
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 页面销毁时取消定时器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 格式化倒计时为 时:分:秒
    final String hours = _remainingTime.inHours.toString().padLeft(2, '0');
    final String minutes = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final String seconds = (_remainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '今日剩余次数：${widget.flag}，距离刷新还有: $hours:$minutes:$seconds',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}