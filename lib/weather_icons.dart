// import 'package:flutter/cupertino.dart';
// import 'package:lock_screen_clock/common/MyIcon.dart';
//
// Map<String, IconData> weatherIconMap = {
//   '晴天': IconFontIcons.icon_qintian,
//   '晴天(夜晚)': IconFontIcons.icon_n_qintian,
//   '多云': IconFontIcons.icon_duoyun,
//   '多云(夜晚)': IconFontIcons.icon_n_duoyun,
//   '阵雨': IconFontIcons.icon_zhenyu,
//   '阵雨(夜晚)': IconFontIcons.icon_n__zhenyu,
//   '小雨': IconFontIcons.icon_xiaoyu,
//   '小雨(夜晚)': IconFontIcons.icon_n_xiaoyu,
//   '中雨': IconFontIcons.icon_zhongyu,
//   '中雨(夜晚)': IconFontIcons.icon_n_zhongyu,
//   '大雨': IconFontIcons.icon_n_dayu,
//   '暴雨': IconFontIcons.icon_n_baoyu,
//   '雷阵雨': IconFontIcons.icon_leizhengyun,
//   '雷阵雨(夜晚)': IconFontIcons.icon_nLeizhenyu1,
//   '雷阵雨伴冰雹': IconFontIcons.icon_leizheyubanbingbao,
//   '雷阵雨伴冰雹(夜晚)': IconFontIcons.icon_n_Leizhenyubanbingbao1,
//   '冻雨': IconFontIcons.icon_dongyu,
//   '冻雨(夜晚)': IconFontIcons.icon_n_dongyu,
//   '雨夹雪': IconFontIcons.iocn_yujiaxue,
//   '雨夹雪(夜晚)': IconFontIcons.iocn_n_yujiaxue,
//   '雨加冰雹': IconFontIcons.icon_yujiabingbao,
//   '雨加冰雹(夜晚)': IconFontIcons.icon_n_yujiabengbao,
//   '小雪': IconFontIcons.icon_xiaoxue,
//   '小雪(夜晚)': IconFontIcons.icon_n_xiaoxue,
//   '中雪': IconFontIcons.icon_zhongxue,
//   '中雪(夜晚)': IconFontIcons.icon_n_daxue,
//   '大雪': IconFontIcons.icon_daxue,
//   '大雪(夜晚)': IconFontIcons.icon_n_daxue,
//   '暴雪': IconFontIcons.icon_baoxue,
//   '暴雪(夜晚)': IconFontIcons.icon_n_baoxue,
//   '阵雪': IconFontIcons.icon_zhenxue,
//   '阵雪(夜晚)': IconFontIcons.icon_n_zhengxue,
//   '扬沙': IconFontIcons.icon_yangsha,
//   '扬沙(夜晚)': IconFontIcons.icon_n_yangsa,
//   '浮尘': IconFontIcons.icon_shachengbao,
//   '浮尘(夜晚)': IconFontIcons.icon_n_shachengbao,
//   // '沙尘暴': null, // 缺少对应图标
//   '雾': IconFontIcons.icon_wu,
//   '雾(夜晚)': IconFontIcons.icon_n_wu,
//   '雾霾': IconFontIcons.icon_wumai,
//   '雾霾(夜晚)': IconFontIcons.icon_n_wumai,
//   '阴': IconFontIcons.icon_yintian,
//   '阴(夜晚)': IconFontIcons.icon_n_yintain,
//   'default': IconFontIcons.icon_weizhi,
// };


import 'package:flutter/cupertino.dart';
import 'package:lock_screen_clock/common/MyIcon.dart';

IconData WeatherIcon(String weatherStatus) {
  // 获取当前时间
  final now = DateTime.now();
  // 判断是白天还是夜晚
  final isNight = now.hour >= 19 || now.hour < 7;

  final weatherIconMap = {
    '晴': isNight ? IconFontIcons.icon_n_qintian : IconFontIcons.icon_qintian,
    '多云': isNight ? IconFontIcons.icon_n_duoyun : IconFontIcons.icon_duoyun,
    '阵雨': isNight ? IconFontIcons.icon_n__zhenyu : IconFontIcons.icon_zhenyu,
    '小雨': isNight ? IconFontIcons.icon_n_xiaoyu : IconFontIcons.icon_xiaoyu,
    '中雨': isNight ? IconFontIcons.icon_n_zhongyu : IconFontIcons.icon_zhongyu,
    '大雨': IconFontIcons.icon_n_dayu,
    '暴雨': IconFontIcons.icon_n_baoyu,
    '雷阵雨': isNight ? IconFontIcons.icon_nLeizhenyu1 : IconFontIcons.icon_leizhengyun,
    '雷阵雨伴冰雹': isNight ? IconFontIcons.icon_n_Leizhenyubanbingbao1 : IconFontIcons.icon_leizheyubanbingbao,
    '冻雨': isNight ? IconFontIcons.icon_n_dongyu : IconFontIcons.icon_dongyu,
    '雨夹雪': isNight ? IconFontIcons.iocn_n_yujiaxue : IconFontIcons.iocn_yujiaxue,
    '雨加冰雹': isNight ? IconFontIcons.icon_n_yujiabengbao : IconFontIcons.icon_yujiabingbao,
    '小雪': isNight ? IconFontIcons.icon_n_xiaoxue : IconFontIcons.icon_xiaoxue,
    '中雪': isNight ? IconFontIcons.icon_n_zhongxue : IconFontIcons.icon_zhongxue,
    '大雪': isNight ? IconFontIcons.icon_n_daxue : IconFontIcons.icon_daxue,
    '暴雪': isNight ? IconFontIcons.icon_n_baoxue : IconFontIcons.icon_baoxue,
    '阵雪': isNight ? IconFontIcons.icon_n_zhengxue : IconFontIcons.icon_zhenxue,
    '扬沙': isNight ? IconFontIcons.icon_n_yangsa : IconFontIcons.icon_yangsha,
    '浮尘': isNight ? IconFontIcons.icon_n_shachengbao : IconFontIcons.icon_shachengbao,
    '雾': isNight ? IconFontIcons.icon_n_wu : IconFontIcons.icon_wu,
    '雾霾': isNight ? IconFontIcons.icon_n_wumai : IconFontIcons.icon_wumai,
    '阴': isNight ? IconFontIcons.icon_n_yintain : IconFontIcons.icon_yintian,
  };

  return weatherIconMap[weatherStatus] ?? IconFontIcons.icon_weizhi;
}