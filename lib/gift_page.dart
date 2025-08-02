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
      body: const Center(child: Text("页面内容")),
    );
  }
}