
mixin DateHelperMixin {
  // 获取当前日期信息
  Map<String, dynamic> getCurrentDateInfo() {
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month; // 注意：月份是从1开始的，不是从0开始的
    int day = now.day;

    // weekday的值从1（星期一）到7（星期日）
    int weekdayIndex = now.weekday;

    // 创建一个列表来存储星期的名称
    List<String> weekdays = [
      '星期一',
      '星期二',
      '星期三',
      '星期四',
      '星期五',
      '星期六',
      '星期日',
    ];

    // 根据weekdayIndex获取对应的星期名称
    String weekday = weekdays[weekdayIndex - 1];

    return {
      'year': year,
      'month': month,
      'day': day,
      'weekday': weekday,
      "now": now
    };
  }
}
