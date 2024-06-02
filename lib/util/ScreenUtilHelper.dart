import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScreenUtilHelper {
  // 获取屏幕宽度
  static double get screenWidth => ScreenUtil().screenWidth;

  // 获取屏幕高度
  static double get screenHeight => ScreenUtil().screenHeight;

  // 获取屏幕像素密度
  static double? get pixelRatio => ScreenUtil().pixelRatio;

  // 获取状态栏高度
  static double get statusBarHeight => ScreenUtil().statusBarHeight;

  // 获取底部安全区域高度
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;

  // 获取宽度缩放因子
  static double get scaleWidth => ScreenUtil().scaleWidth;

  // 获取高度缩放因子
  static double get scaleHeight => ScreenUtil().scaleHeight;

  // 设置宽度
  static double setWidth(double width) => width.w;

  // 设置高度
  static double setHeight(double height) => height.h;

  // 设置字体大小
  static double setSp(double fontSize) => fontSize.sp;
}
