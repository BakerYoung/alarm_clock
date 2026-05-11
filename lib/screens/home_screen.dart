import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('智能闹钟')),
      body: const Center(child: Text('Hello, Alarm Clock!')),
    );
  }
}
