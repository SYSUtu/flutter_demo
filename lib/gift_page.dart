import 'package:flutter/material.dart';

class GiftPage extends StatefulWidget{
  const GiftPage({super.key});

  @override
  State<GiftPage> createState() => _MyGiftPageState();
}

class _MyGiftPageState extends State<GiftPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        // 子组件列表（可以放多个Widget）
          children: [
            RewardLottery(),
            TaskList()
    ]
      )
    );
  }
}

class TaskList extends StatefulWidget{
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _MyTaskListState();
}

class _MyTaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    // 只返回具体内容，不包含Scaffold
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft, // 左对齐
          child: const Text(
            '大奖兑换',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10), // 间距
        const Center(child: Text("各种任务")),
        // 可以添加更多任务相关的布局...
      ],
    );
  }
}

class RewardLottery extends StatefulWidget{
  const RewardLottery({super.key});

  @override
  State<RewardLottery> createState() => _MyRewardLotteryState();
}

class _MyRewardLotteryState extends State<RewardLottery> {
  @override
  Widget build(BuildContext context) {
    // 只返回具体内容，不包含Scaffold
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft, // 左对齐
          child: const Text(
            '欢乐抽奖',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10), // 间距
        const Center(child: Text("各种任务")),
        // 可以添加更多任务相关的布局...
      ],
    );
  }
}
