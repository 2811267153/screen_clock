import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/notification_service.dart';
import '../util/ScreenUtilHelper.dart';

class SomePage extends StatefulWidget {

  final Color color;

  const SomePage(
      {super.key,
        required this.color});

  @override
  State<SomePage> createState() => _SomePageState();
}

class _SomePageState extends State<SomePage> {
  final NotificationService notificationService = NotificationService.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    notificationService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Align(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            SizedBox(
              height: ScreenUtilHelper.setHeight(20),
            ),
            Text("通知中心", style: TextStyle(
                color: widget.color,
                fontSize: ScreenUtilHelper.setSp(35),
                fontWeight: FontWeight.bold),),
            Expanded(
              child: ListView.builder(
                itemCount: notificationService.notifications.length,
                itemBuilder: (context, index) {
                  final notification = notificationService.notifications[index];
                  return ListTile(
                    title: Text(notification['title'] ?? ''),
                    subtitle: Text(notification['content'] ?? ''),
                  );
                },
              ),
            )
          ],
        ),
      ),
    ));
  }
} 