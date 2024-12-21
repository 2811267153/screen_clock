import 'package:flutter/cupertino.dart';

import '../common/MyIcon.dart';

IconData WeatherIcon(String weatherStatus) {
  final now = DateTime.now();
  final isNight = now.hour >= 19 || now.hour < 7;

  // 转小写避免大小写问题
  final normalizedWeatherStatus = weatherStatus.toLowerCase();
  print(weatherStatus);

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
