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
        TextWithButtonRow(taskConent:'1. 30分钟马杀鸡',point:10),
        TextWithButtonRow(taskConent:'2. 老公给做一顿大餐',point:30),
        TextWithButtonRow(taskConent:'3. 一起去电影院看电影',point:45),
        TextWithButtonRow(taskConent:'4. 奖励一个大大的榴莲',point:60),
        TextWithButtonRow(taskConent:'5. 200元微信红包',point:100),
        TextWithButtonRow(taskConent:'6. 出去吃一顿大大大餐',point:188),
        TextWithButtonRow(taskConent:'7. 说走就走的旅行',point:365),
        TextWithButtonRow(taskConent:'8. 老公给报销瘦脸针',point:500),
        TextWithButtonRow(taskConent:'9. 老公给买大黄金',point:666),
        TextWithButtonRow(taskConent:'10. 实现一个究极大愿望',point:999),
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

class TextWithButtonRow extends StatelessWidget {
  final String taskConent;
  final int point;
  const TextWithButtonRow({super.key,required this.taskConent, required this.point});

  @override
  Widget build(BuildContext context) {
    return Row(
          // 主轴对齐方式：两端对齐（文本靠左，按钮靠右）
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // 交叉轴对齐方式：垂直居中
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 文本部分
            Padding(
              // 只设置左边距为16像素（可根据需要调整数值）
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                '$taskConent',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),

            // 按钮部分
            ElevatedButton(
              onPressed: () {
                // 按钮点击逻辑
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('快去找你老公兑现吧！！！')),
                );
              },
              style: ElevatedButton.styleFrom(
                // 背景色（ ElevatedButton 特有，凸起按钮的背景）
                backgroundColor: Colors.teal, // 正常状态
                disabledBackgroundColor: Colors.grey[300], // 禁用状态

                // 文本颜色
                foregroundColor: Colors.white, // 正常状态文字/图标颜色
                disabledForegroundColor: Colors.grey[600], // 禁用状态文字/图标颜色

                // 内边距（按钮内容与边缘的距离）
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                // 最小尺寸（按钮的最小宽高）
                minimumSize: Size(80, 40), // 宽100，高40
              ),
              child: Text('-$point分'),
            ),
          ],
    );
  }
}