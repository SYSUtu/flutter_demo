import 'package:flutter/material.dart';
import 'package:flutter_demo/lottery_wheel.dart';

// 主页面保持不变
class GiftPage extends StatefulWidget {
  const GiftPage({super.key});

  @override
  State<GiftPage> createState() => _MyGiftPageState();
}

class _MyGiftPageState extends State<GiftPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自律分')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const RewardLottery(),
            const Divider(height: 20, thickness: 1),
            const TaskList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// TaskList和TextWithButtonRow保持不变
class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _MyTaskListState();
}

class _MyTaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              '大奖兑换',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10,
          itemBuilder: (context, index) {
            final List<Map<String, dynamic>> rewards = [
              {'content': '30分钟马杀鸡', 'points': 10},
              {'content': '老公给做一顿大餐', 'points': 30},
              {'content': '一起去电影院看电影', 'points': 45},
              {'content': '奖励一个大大的榴莲', 'points': 60},
              {'content': '200元微信红包', 'points': 100},
              {'content': '出去吃一顿大大大餐', 'points': 188},
              {'content': '说走就走的旅行', 'points': 365},
              {'content': '老公给报销瘦脸针', 'points': 500},
              {'content': '老公给买大黄金', 'points': 666},
              {'content': '实现一个究极大愿望', 'points': 999},
            ];
            return TextWithButtonRow(
              taskConent: '${index + 1}. ${rewards[index]['content']}',
              point: rewards[index]['points'],
            );
          },
        ),
      ],
    );
  }
}

class TextWithButtonRow extends StatelessWidget {
  final String taskConent;
  final int point;

  const TextWithButtonRow({
    super.key,
    required this.taskConent,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              taskConent,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已兑换 ${taskConent.split('.')[1].trim()}，消耗$point分'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(80, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text('-$point分'),
            ),
          ),
        ],
      ),
    );
  }
}

// RewardLottery保持不变
class RewardLottery extends StatefulWidget {
  const RewardLottery({super.key});

  @override
  State<RewardLottery> createState() => _MyRewardLotteryState();
}

class _MyRewardLotteryState extends State<RewardLottery> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              '欢乐抽奖',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 10),
        LotteryWheel(
          maxSize: screenSize.width * 0.85,
          items: [
            LotteryItem(name: "+2积分", color: Colors.red, icon: Icons.star, probability: 1),
            LotteryItem(name: "+1积分", color: Colors.orange, icon: Icons.emoji_events, probability: 2),
            LotteryItem(name: "三等奖", color: Colors.yellow, icon: Icons.card_giftcard, probability: 3),
            LotteryItem(name: "谢谢参与", color: Colors.black, icon: Icons.sentiment_neutral, probability: 10),
            LotteryItem(name: "谢谢参与", color: Colors.pink, icon: Icons.sentiment_neutral, probability: 10),
            LotteryItem(name: "谢谢参与", color: Colors.pinkAccent, icon: Icons.sentiment_neutral, probability: 10),
            LotteryItem(name: "谢谢参与", color: Colors.indigo, icon: Icons.sentiment_neutral, probability: 10),
          ],
        ),
      ],
    );
  }
}