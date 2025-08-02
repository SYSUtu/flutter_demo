import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_demo/MyTabbedPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小陈陈的激励计划',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blueAccent,
        // 优化colorScheme配置，使onPrimary为深色
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          onPrimary: Colors.black87, // 手动指定primary背景上的文字为深黑色
        ),
      ),
      home: const MyTabbedPage(),
    );
  }
}

