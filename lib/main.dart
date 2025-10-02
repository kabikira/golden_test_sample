import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Asset Sample')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/sample1.png', width: 120, height: 120),
              Image.asset(
                'assets/images/Tesseract.gif',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),
              const Text('Hello World!'),
            ],
          ),
        ),
      ),
    );
  }
}
