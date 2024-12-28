import 'package:flutter/services.dart';

class NativeToast {
  static const platform =
      MethodChannel('com.example.flutter_screen_clock/toast');
  static bool _isShowingToast = false;

  static Future<void> showToast(String message) async {
    if (_isShowingToast) return;

    try {
      _isShowingToast = true;
      await platform.invokeMethod('showToast', {'message': message});
    } on PlatformException catch (e) {
      print("Platform Exception: ${e.message}");
    } catch (e) {
      print("调用原生Toast失败: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 1000));
      _isShowingToast = false;
    }
  }
}
