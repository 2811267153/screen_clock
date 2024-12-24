import 'package:intl/intl.dart';

class Time {
  final int h;
  final int m;

  Time(this.h, this.m);
}

typedef Callback<T> = void Function(T);

class Utils {
  int calculateTimestamp(Time time) {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final timeDateTime = DateTime(now.year, now.month, now.day, time.h, time.m);
    final timeDifference = timeDateTime.difference(midnight);
    return timeDifference.inSeconds;
  }

  String formatTimeToHour(dynamic dateTimeString) {
    /// 将时间格式化为 "HH:mm" 的形式
    return DateFormat('HH:mm').format(dateTimeString);
  }
}
