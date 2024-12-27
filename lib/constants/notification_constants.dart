import 'package:flutter/material.dart';
import '../util/ScreenUtilHelper.dart';

class NotificationConstants {
  // 动画相关
  static const int animationDuration = 800; // 毫秒
  static const double scaleBeginNew = 0.8;
  static const double scaleBeginExisting = 1.0;
  static const double scaleEnd = 1.0;
  static const double opacityBeginNew = 0.5;
  static const double opacityBeginExisting = 1.0;
  static const double opacityEnd = 1.0;

  // 布局相关
  static double get itemHeight => ScreenUtilHelper.setHeight(100);
  static double get iconSize => ScreenUtilHelper.setWidth(40);
  static double get iconSpacing => ScreenUtilHelper.setWidth(12);
  static double get leftPadding => ScreenUtilHelper.setWidth(8);

  // 文字样式相关
  static double get titleFontSize => ScreenUtilHelper.setSp(50);
  static double get contentFontSize => ScreenUtilHelper.setSp(40);
  static double get headerFontSize => ScreenUtilHelper.setSp(35);
  static const double contentOpacity = 0.7;

  // 动画曲线
  static const Curve animationCurve = Curves.easeOut;
  static const double animationIntervalEnd = 0.6;
}
