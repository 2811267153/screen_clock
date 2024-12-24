import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ToDoListService extends GetxController {
  static ToDoListService get instance => Get.find();
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  // 日历列表和事件列表
  final RxList<Calendar> calendars = <Calendar>[].obs;
  final RxList<Event> events = <Event>[].obs;

  // 加载状态
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    _initTodoList();
  }

  void _initTodoList() async {
    try {
      // 获取权限检查结果
      final result = await _deviceCalendarPlugin.hasPermissions();

      if (result.isSuccess && result.data == true) {

        // 获取日历列表
        final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
        if (calendarsResult.isSuccess && calendarsResult.data != null) {
          final List<Calendar> calendars = calendarsResult.data!;

          // 遍历每个日历，获取其事件
          for (var calendar in calendars) {
            print('日历名称: ${calendar.name}');
            print('日历ID: ${calendar.id}');

            // 获取当前日历的事件
            await _fetchEvents(calendar.id!);
          }
        } else {
          // print('获取日历列表失败: ${calendarsResult.errorMessages?.join(", ")}');
        }
      } else {
        debugPrint("日程权限未授予，请在系统设置中开启日程访问权限");
      }
    } catch (e) {
      debugPrint("检查日程权限出错: $e");
    }
  }


  _fetchEvents(String calendarId) async {
    try {
      // 设置时间范围
      final DateTime startDate = DateTime.now();
      final DateTime endDate = DateTime.now().add(Duration(days: 7));

      // 获取事件
      final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(startDate: startDate, endDate: endDate),
      );

      if (eventsResult.isSuccess && eventsResult.data != null) {
        // final List<Event> events = eventsResult.data!;
        print("eventsResult.data!${eventsResult.data![0].start}");
        events.assignAll(eventsResult.data!);
      } else {
        // print('获取事件失败: ${eventsResult.errorMessages?.join(", ")}');
      }
    } catch (e) {
      print('获取事件时出错: $e');
    }
  }


}