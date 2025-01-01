import 'package:chinese_lunar_calendar/chinese_lunar_calendar.dart';
import 'package:lunar/lunar.dart';

class LunarDateUtil {
  static String getCurrentLunarDate() {
    final now = DateTime.now();
    final lunar = Lunar.fromDate(now);
    return "农历${lunar.getYearInGanZhi()}年${lunar.getMonthInChinese()}月${lunar.getDayInChinese()}日（阴历）";
  }

  static String _toChineseYear(int year) {
    const chineseNumbers = ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
    return year
        .toString()
        .split('')
        .map((e) => chineseNumbers[int.parse(e)])
        .join('');
  }

  static String _toChineseMonth(int month) {
    const chineseMonths = [
      '正',
      '二',
      '三',
      '四',
      '五',
      '六',
      '七',
      '八',
      '九',
      '十',
      '冬',
      '腊'
    ];
    return chineseMonths[month - 1];
  }

  static String _toChineseDay(int day) {
    const chineseDays = [
      '初一',
      '初二',
      '初三',
      '初四',
      '初五',
      '初六',
      '初七',
      '初八',
      '初九',
      '初十',
      '十一',
      '十二',
      '十三',
      '十四',
      '十五',
      '十六',
      '十七',
      '十八',
      '十九',
      '二十',
      '廿一',
      '廿二',
      '廿三',
      '廿四',
      '廿五',
      '廿六',
      '廿七',
      '廿八',
      '廿九',
      '三十'
    ];
    return chineseDays[day - 1];
  }
}