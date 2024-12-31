import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 设置全屏和保持屏幕常亮
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "锁屏界面",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
