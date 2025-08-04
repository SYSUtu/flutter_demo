import 'package:flutter/material.dart';
import 'package:flutter_demo/task_page.dart';
import 'package:flutter_demo/gift_page.dart';

class MyTabbedPage extends StatefulWidget {
  const MyTabbedPage({super.key});

  @override
  State<MyTabbedPage> createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage> {
  // 定义两个Tab的内容
  final List<Widget> _tabs = const [
    Tab(text: '每日任务'),
    Tab(text: '奖励兑换'),
  ];

  // 定义两个Tab对应的页面内容
  final List<Widget> _tabViews = const [
    Center(child: TaskPage()),
    Center(child: GiftPage()),
  ];

  @override
  Widget build(BuildContext context) {
    // 获取全局主题数据
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('小陈陈的激励计划'),
          backgroundColor: Colors.teal,
          // 添加TabBar
          bottom: TabBar(
            tabs: _tabs,
            // 指示器颜色（深蓝）
            indicatorColor: Colors.black,
            // 指示器高度
            indicatorWeight: 1,
            // 选中标签文字颜色（深蓝）
            labelColor: Colors.black,
            // 未选中标签文字颜色（灰色）
            unselectedLabelColor: Colors.grey[800],
            // 选中标签文字样式（可选）
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
            // 未选中标签文字样式（可选）
            unselectedLabelStyle: const TextStyle(
              fontSize: 17,
            ),
            // 去除TabBar默认的内边距（可选）
            labelPadding: const EdgeInsets.symmetric(vertical: 5),
          ),
        ),
        // 添加Tab内容区域
        body: TabBarView(
          children: _tabViews,
        ),
      ),
    );
  }
}