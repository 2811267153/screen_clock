import 'package:flutter/cupertino.dart';

import '../common/MyIcon.dart';

IconData WeatherIcon(String weatherStatus) {
  final now = DateTime.now();
  final isNight = now.hour >= 19 || now.hour < 7;

  // 转小写避免大小写问题
  final normalizedWeatherStatus = weatherStatus.toLowerCase();

  final weatherIconMap = {
    '晴'.toLowerCase(): isNight ? IconFontIcons.icon_n_qintian : IconFontIcons.icon_qintian,
    '多云'.toLowerCase(): isNight ? IconFontIcons.icon_n_duoyun : IconFontIcons.icon_duoyun,
    '阵雨'.toLowerCase(): isNight ? IconFontIcons.icon_n__zhenyu : IconFontIcons.icon_zhenyu,
    '小雨'.toLowerCase(): isNight ? IconFontIcons.icon_n_xiaoyu : IconFontIcons.icon_xiaoyu,
    '中雨'.toLowerCase(): isNight ? IconFontIcons.icon_n_zhongyu : IconFontIcons.icon_zhongyu,
    '大雨'.toLowerCase(): IconFontIcons.icon_n_dayu,
    '暴雨'.toLowerCase(): IconFontIcons.icon_n_baoyu,
    '雷阵雨'.toLowerCase(): isNight ? IconFontIcons.icon_nLeizhenyu1 : IconFontIcons.icon_leizhengyun,
    '雷阵雨伴冰雹'.toLowerCase(): isNight ? IconFontIcons.icon_n_Leizhenyubanbingbao1 : IconFontIcons.icon_leizheyubanbingbao,
    '冻雨'.toLowerCase(): isNight ? IconFontIcons.icon_n_dongyu : IconFontIcons.icon_dongyu,
    '雨夹雪'.toLowerCase(): isNight ? IconFontIcons.iocn_n_yujiaxue : IconFontIcons.iocn_yujiaxue,
    '雨加冰雹'.toLowerCase(): isNight ? IconFontIcons.icon_n_yujiabengbao : IconFontIcons.icon_yujiabingbao,
    '小雪'.toLowerCase(): isNight ? IconFontIcons.icon_n_xiaoxue : IconFontIcons.icon_xiaoxue,
    '中雪'.toLowerCase(): isNight ? IconFontIcons.icon_n_zhongxue : IconFontIcons.icon_zhongxue,
    '大雪'.toLowerCase(): isNight ? IconFontIcons.icon_n_daxue : IconFontIcons.icon_daxue,
    '暴雪'.toLowerCase(): isNight ? IconFontIcons.icon_n_baoxue : IconFontIcons.icon_baoxue,
    '阵雪'.toLowerCase(): isNight ? IconFontIcons.icon_n_zhengxue : IconFontIcons.icon_zhenxue,
    '扬沙'.toLowerCase(): isNight ? IconFontIcons.icon_n_yangsa : IconFontIcons.icon_yangsha,
    '浮尘'.toLowerCase(): isNight ? IconFontIcons.icon_n_shachengbao : IconFontIcons.icon_shachengbao,
    '雾'.toLowerCase(): isNight ? IconFontIcons.icon_n_wu : IconFontIcons.icon_wu,
    '雾霾'.toLowerCase(): isNight ? IconFontIcons.icon_n_wumai : IconFontIcons.icon_wumai,
    '阴'.toLowerCase(): isNight ? IconFontIcons.icon_n_yintain : IconFontIcons.icon_yintian,
  };

  return weatherIconMap[normalizedWeatherStatus] ?? IconFontIcons.icon_weizhi;
}

IconData DayNumberIcon(String num) {
// 第二个Map - D系列（shuzi）
  final Map<String, IconData> dIcons = {
    '0': const IconData(0xe60d, fontFamily: "IconFontIcons"),
    '1': const IconData(0xe60e, fontFamily: "IconFontIcons"),
    '2': const IconData(0xe60f, fontFamily: "IconFontIcons"),
    '3': const IconData(0xe610, fontFamily: "IconFontIcons"),
    '4': const IconData(0xe611, fontFamily: "IconFontIcons"),
    '5': const IconData(0xe612, fontFamily: "IconFontIcons"),
    '6': const IconData(0xe613, fontFamily: "IconFontIcons"),
    '7': const IconData(0xe614, fontFamily: "IconFontIcons"),
    '8': const IconData(0xe615, fontFamily: "IconFontIcons"),
    '9': const IconData(0xe616, fontFamily: "IconFontIcons"),
  };

  return dIcons['D$num'] ?? dIcons['D0']!;
}

IconData TimeNumberIcon(String num) {
// 第二个Map - D系列（shuzi）
  final Map<String, IconData> dIcons = {
    '0': const IconData(0xe637, fontFamily: "IconFontIcons"),
    '1': const IconData(0xe638, fontFamily: "IconFontIcons"),
    '2': const IconData(0xe639, fontFamily: "IconFontIcons"),
    '3': const IconData(0xe63a, fontFamily: "IconFontIcons"),
    '4': const IconData(0xe62b, fontFamily: "IconFontIcons"), // 注意：原列表中没有4，我用了一个占位值
    '5': const IconData(0xe62c, fontFamily: "IconFontIcons"),
    '6': const IconData(0xe62d, fontFamily: "IconFontIcons"),
    '7': const IconData(0xe62e, fontFamily: "IconFontIcons"),
    '8': const IconData(0xe74c, fontFamily: "IconFontIcons"),
    '9': const IconData(0xe748, fontFamily: "IconFontIcons"),
  };

  return dIcons['D$num'] ?? dIcons['D0']!;
}


