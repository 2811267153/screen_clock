import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import '../util/nativeToast.dart';

/// 通知服务类，用于管理通知的监听和处理
class NotificationService extends GetxController {
  /// 获取 NotificationService 的单例
  static NotificationService get instance => Get.find();

  /// 存储通知列表的可观察数组
  final notifications = [].obs;

  /// 标记通知监听服务是否正在运行
  bool _isServiceRunning = false;

  /// 通知监听的订阅对象
  StreamSubscription<ServiceNotificationEvent>? _subscription;

  @override
  void onInit() {
    super.onInit();
    // 初始化时暂不检查权限
  }

  /// 检查通知权限状态
  /// 如果没有权限，会请求权限并等待用户操作
  /// 返回最终的权限状态
  Future<bool> checkNotificationPermission() async {
    final bool res = await NotificationListenerService.isPermissionGranted();
    debugPrint("通知权限状态: $res");
    if (!res) {
      NativeToast.showToast("请先授予当前程序获取通知的权限！");
      final requestRes = await NotificationListenerService.requestPermission();
      debugPrint("通知权限请求结果: $requestRes");

      // 等待用户操作后再次检查权限
      await Future.delayed(const Duration(seconds: 1));
      final finalRes = await NotificationListenerService.isPermissionGranted();
      debugPrint("最终通知权限状态: $finalRes");
      return finalRes;
    }
    return res;
  }

  /// 开始监听通知
  /// 会先检查权限，有权限才开始监听
  Future<void> startListening() async {
    final bool res = await NotificationListenerService.isPermissionGranted();
    debugPrint("通知权限状态: $res");

    if (res && !_isServiceRunning) {
      // 开始监听通知
      _subscription = NotificationListenerService.notificationsStream.listen(
        (event) {
          if (event.packageName == null || event.title == null) return;

          // 构建通知数据对象
          final notification = {
            'packageName': event.packageName,
            'title': event.title,
            'content': event.content,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };

          // 将新通知插入到列表开头
          notifications.insert(0, notification);
        },
      );

      _isServiceRunning = true;
      debugPrint("通知监听服务已启动");
    }
  }

  /// 停止通知监听
  /// 取消订阅并更新服务状态
  Future<void> stopListening() async {
    if (_isServiceRunning) {
      _subscription?.cancel();
      _isServiceRunning = false;
    }
  }
}
