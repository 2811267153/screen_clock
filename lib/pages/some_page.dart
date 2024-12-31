import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../constants/notification_constants.dart';

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
      duration:
          const Duration(milliseconds: NotificationConstants.animationDuration),
      vsync: this,
    );

    _scaleAnimations.clear();
    _slideAnimations.clear();
    _opacityAnimations.clear();

    for (var i = 0; i < notifications.length; i++) {
      // 缩放动画
      _scaleAnimations[i] = Tween<double>(
        begin: i == 0
            ? NotificationConstants.scaleBeginNew
            : NotificationConstants.scaleBeginExisting,
        end: NotificationConstants.scaleEnd,
      ).animate(CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.0, NotificationConstants.animationIntervalEnd,
            curve: NotificationConstants.animationCurve),
      ));

      // 位移动画
      _slideAnimations[i] = Tween<double>(
        begin: i == 0
            ? -NotificationConstants.itemHeight
            : (i - 1) * NotificationConstants.itemHeight,
        end: i * NotificationConstants.itemHeight,
      ).animate(CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.0, NotificationConstants.animationIntervalEnd,
            curve: NotificationConstants.animationCurve),
      ));

      // 透明度动画
      _opacityAnimations[i] = Tween<double>(
        begin: i == 0
            ? NotificationConstants.opacityBeginNew
            : NotificationConstants.opacityBeginExisting,
        end: NotificationConstants.opacityEnd,
      ).animate(CurvedAnimation(
        parent: _mainController!,
        curve: const Interval(0.0, NotificationConstants.animationIntervalEnd,
            curve: NotificationConstants.animationCurve),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "通知中心",
                  style: TextStyle(
                      color: widget.color,
                      fontSize: NotificationConstants.headerFontSize,
                      fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: notificationService.notifications.isEmpty
                      ? Center(
                          child: Text(
                            "暂无通知",
                            style: TextStyle(
                              color: widget.color.withOpacity(0.5),
                              fontSize: NotificationConstants.contentFontSize,
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
                                            NotificationConstants.itemHeight),
                                    child: Transform.scale(
                                      scale: scaleAnimation?.value ?? 1.0,
                                      alignment: Alignment.center,
                                      child: Opacity(
                                        opacity: opacityAnimation?.value ?? 1.0,
                                        child:
                                            _buildListTile(notification, index),
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

  Widget _buildListTile(Map<String, dynamic> notification, int index) {
    return Container(
      padding: EdgeInsets.only(left: NotificationConstants.leftPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: notification['icon'] != null
                ? Image.memory(
                    notification['icon']!,
                    width: NotificationConstants.iconSize,
                    height: NotificationConstants.iconSize,
                  )
                : Icon(
                    Icons.notifications,
                    color: widget.color,
                    size: NotificationConstants.iconSize,
                  ),
          ),
          SizedBox(width: NotificationConstants.iconSpacing),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'] ?? '',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: NotificationConstants.titleFontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  notification['content'] ?? '',
                  style: TextStyle(
                    color: widget.color
                        .withOpacity(NotificationConstants.contentOpacity),
                    fontSize: NotificationConstants.contentFontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
