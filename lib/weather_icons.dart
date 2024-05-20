
// 定义天气状况与图标名称的映射
import 'package:flutter/cupertino.dart';
import 'package:lock_screen_clock/common/MyIcon.dart';

Map<String, IconData> weatherIconMap = {
  '晴': IconFontIcons.iconAQingre,
  '雾霾': IconFontIcons.iconMai,
  '雨夹雪': IconFontIcons.iconYujiaxue,
  '中雪': IconFontIcons.iconZhongxue,
  '浮尘': IconFontIcons.iconFuchen,
  '阵雪': IconFontIcons.iconZhenxue,
  '阴': IconFontIcons.iconAYinleng,
  '龙卷风': IconFontIcons.iconLongjuanfeng,
  '阵雨': IconFontIcons.iconZhenyu,
  'default': IconFontIcons.iconWeizhi,
  '扬沙': IconFontIcons.iconYangsha,
  '雾': IconFontIcons.iconWu,
  '大雪': IconFontIcons.iconDaxue,
  '雷阵雨': IconFontIcons.iconLeizhenyu,
  '飓风':IconFontIcons.iconXiaoxue,
  '暴雪': IconFontIcons.iconBaoxue,
  '小雪': IconFontIcons.iconXiaoxue,
  '沙尘暴': IconFontIcons.iconAShachenbaoqiangshachenbao,
  '风': IconFontIcons.iconFeng,
  '冰雹': IconFontIcons.iconLeizhenyubanyoubingbao,
  '中雨': IconFontIcons.iconZhongyu,
  '大雨': IconFontIcons.iconDayu,
  '大风': IconFontIcons.iconDafeng,
  '小雨': IconFontIcons.iconXiaoyu,
  '暴雨': IconFontIcons.iconABaoyudabaoyutedabaoyu,
  '冻雨': IconFontIcons.iconDongyu,
  // 添加其他天气状况及其对应的图标名称
};
