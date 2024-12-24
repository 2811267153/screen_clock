import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/data.dart';
import '../services/notification_service.dart';
import '../util/ScreenUtilHelper.dart';

class SomePage extends StatefulWidget {
  final Color color;

  const SomePage({super.key, required this.color});

  @override
  State<SomePage> createState() => _SomePageState();
}

class _SomePageState extends State<SomePage> with TickerProviderStateMixin {
  final NotificationService notificationService = NotificationService.instance;
  AnimationController? _mainController;
  final Map<int, Animation<double>> _scaleAnimations = {};
  final Map<int, Animation<double>> _slideAnimations = {};
  final Map<int, Animation<double>> _opacityAnimations = {};

  @override
  void initState() {
    super.initState();
    ever(notificationService.notifications, (notifications) {
      if (notifications.isNotEmpty) {
        _createAnimations(notifications);
      }
    });
  }

  void _createAnimations(List notifications) {
    if (!mounted) return;

    _mainController?.dispose();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimations.clear();
    _slideAnimations.clear();
    _opacityAnimations.clear();

    final itemHeight = ScreenUtilHelper.setHeight(56);

    for (var i = 0; i < notifications.length; i++) {
      // 缩放动画：只对新项使用
      _scaleAnimations[i] = Tween<double>(
        begin: i == 0 ? 0.8 : 1.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ));

      // 位移动画
      _slideAnimations[i] = Tween<double>(
        begin: i == 0
            ? -itemHeight // 新项从上方进入
            : (i - 1) * itemHeight, // 已有项从当前位置开始
        end: i * itemHeight, // 所有项都移动到新位置
      ).animate(CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ));

      // 透明度动画：只对新项使用
      _opacityAnimations[i] = Tween<double>(
        begin: i == 0 ? 0.5 : 1.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ));
    }

    _mainController?.forward();
  }

  @override
  void dispose() {
    _mainController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Align(
          child: Container(
            color: Colors.black,
            child: Column(
              children: [
                Text(
                  "通知中心",
                  style: TextStyle(
                      color: widget.color,
                      fontSize: ScreenUtilHelper.setSp(35),
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: notificationService.notifications.isEmpty
                      ? Center(
                          child: Text(
                            "暂无通知",
                            style: TextStyle(
                              color: widget.color.withOpacity(0.5),
                              fontSize: ScreenUtilHelper.setSp(30),
                            ),
                          ),
                        )
                      : Stack(
                          children: List.generate(
                            notificationService.notifications.length,
                            (index) {
                              final notification =
                                  notificationService.notifications[index];
                              final scaleAnimation = _scaleAnimations[index];
                              final slideAnimation = _slideAnimations[index];
                              final opacityAnimation =
                                  _opacityAnimations[index];

                              return AnimatedBuilder(
                                animation: _mainController ??
                                    const AlwaysStoppedAnimation(1.0),
                                builder: (context, child) {
                                  return Positioned(
                                    left: 0,
                                    right: 0,
                                    top: slideAnimation?.value ??
                                        (index *
                                            (ScreenUtilHelper.setHeight(56))),
                                    child: Transform.scale(
                                      scale: scaleAnimation?.value ?? 1.0,
                                      alignment: Alignment.center,
                                      child: Opacity(
                                        opacity: opacityAnimation?.value ?? 1.0,
                                        // 为第一个项添加 GlobalKey
                                        child: index == 0
                                            ? ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal:
                                                      ScreenUtilHelper.setWidth(
                                                          8),
                                                ),
                                                leading: notification['icon'] !=
                                                        null
                                                    ? Image.memory(
                                                        notification['icon']!,
                                                        width: ScreenUtilHelper
                                                            .setWidth(40),
                                                        height: ScreenUtilHelper
                                                            .setWidth(40),
                                                      )
                                                    : Icon(
                                                        Icons.notifications,
                                                        color: widget.color,
                                                        size: ScreenUtilHelper
                                                            .setWidth(40),
                                                      ),
                                                title: Text(
                                                  notification['title'] ?? '',
                                                  style: TextStyle(
                                                      color: widget.color),
                                                ),
                                                subtitle: Text(
                                                  notification['content'] ?? '',
                                                  style: TextStyle(
                                                    color: widget.color
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              )
                                            : ListTile(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal:
                                                      ScreenUtilHelper.setWidth(
                                                          8),
                                                ),
                                                leading: notification['icon'] !=
                                                        null
                                                    ? Image.memory(
                                                        notification['icon']!,
                                                        width: ScreenUtilHelper
                                                            .setWidth(40),
                                                        height: ScreenUtilHelper
                                                            .setWidth(40),
                                                      )
                                                    : Icon(
                                                        Icons.notifications,
                                                        color: widget.color,
                                                        size: ScreenUtilHelper
                                                            .setWidth(40),
                                                      ),
                                                title: Text(
                                                  notification['title'] ?? '',
                                                  style: TextStyle(
                                                      color: widget.color),
                                                ),
                                                subtitle: Text(
                                                  notification['content'] ?? '',
                                                  style: TextStyle(
                                                    color: widget.color
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ));
  }
}
