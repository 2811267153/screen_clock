import 'package:flutter/services.dart';

class NativeToast {
  static const platform =
      MethodChannel('com.example.flutter_screen_clock/toast');

  static Future<void> showToast(String message) async {
    try {
      await platform.invokeMethod('showToast', {'message': message});
    } on PlatformException catch (e) {
      print("调用原生Toast失败: ${e.message}");
    }
  }
}
