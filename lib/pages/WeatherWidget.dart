import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:get/get.dart';
import 'package:lock_screen_clock/common/ShakeAnimationWidget.dart';
import 'package:lock_screen_clock/model/LunisolarCalendar.dart';
import 'package:lock_screen_clock/model/Weather.dart';
import 'package:lock_screen_clock/util/ScreenUtilHelper.dart';
import 'package:lock_screen_clock/weather_icons.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

import '../common/MyIcon.dart';

class WeatherWidget extends StatefulWidget {
  final WeatherModel weatherModel;
  final LunisolarCalendarModel lunisolarCalendarModel;
  final Color color;

  const WeatherWidget(
      {super.key,
      required this.weatherModel,
      required this.lunisolarCalendarModel,
      required this.color});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget>
    with SingleTickerProviderStateMixin {
  RxBool isShowMask = true.obs;
  late AnimationController _controller;
  final selectedExpanded = RxnInt();
  late PageController _pageController;

  double _viewportFraction = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Center(
          child: Row(
            children: [
              ExpandedComponent(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtilHelper.setHeight(20.0)),
                        child: Text(
                          getFormattedDate(),
                          style: TextStyle(
                              color: widget.color,
                              fontSize: ScreenUtilHelper.setSp(40),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtilHelper.setHeight(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                        widget.lunisolarCalendarModel.result!
                                                .nongli ??
                                            "",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: widget.color,
                                            fontSize:
                                                ScreenUtilHelper.setSp(15),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2)),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtilHelper.setHeight(10),
                                ),
                                Transform(
                                  transform: Matrix4.diagonal3Values(
                                      1.3, 1.0, 1.0), // 调整拉伸比例
                                  child: Text(
                                    DateTime.now()
                                        .day
                                        .toString()
                                        .padLeft(2, '0'),
                                    style: TextStyle(
                                      color: widget.color,
                                      fontSize: ScreenUtilHelper.setSp(205),
                                      fontWeight: FontWeight.w700,
                                      height: 0.8,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtilHelper.setHeight(10),
                                ),
                                _goodDay(
                                    widget.lunisolarCalendarModel.result!.yi ??
                                        []),
                                SizedBox(
                                  height: ScreenUtilHelper.setHeight(10),
                                ),
                                _noGoodDay(
                                    widget.lunisolarCalendarModel.result!.ji ??
                                        []),
                              ],
                            ),
                          ),
                          Column(
                            children: getWeekday().split('').map((char) {
                              return Container(
                                padding: EdgeInsets.only(
                                    left: ScreenUtilHelper.setWidth(20)),
                                child: Text(
                                  char,
                                  style: TextStyle(
                                      color: widget.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: ScreenUtilHelper.setSp(80)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  ),Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: ScreenUtilHelper.setHeight(20.0)),
                        child: Text(
                          getFormattedDate(),
                          style: TextStyle(
                              color: widget.color,
                              fontSize: ScreenUtilHelper.setSp(40),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtilHelper.setHeight(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                        widget.lunisolarCalendarModel.result!
                                                .nongli ??
                                            "",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: widget.color,
                                            fontSize:
                                                ScreenUtilHelper.setSp(15),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 2)),
                                  ],
                                ),
                                SizedBox(
                                  height: ScreenUtilHelper.setHeight(10),
                                ),
                                Transform(
                                  transform: Matrix4.diagonal3Values(
                                      1.3, 1.0, 1.0), // 调整拉伸比例
                                  child: Text(
                                    DateTime.now()
                                        .day
                                        .toString()
                                        .padLeft(2, '0'),
                                    style: TextStyle(
                                      color: widget.color,
                                      fontSize: ScreenUtilHelper.setSp(205),
                                      fontWeight: FontWeight.w700,
                                      height: 0.8,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  height: ScreenUtilHelper.setHeight(10),
                                ),
                                _goodDay(
                                    widget.lunisolarCalendarModel.result!.yi ??
                                        []),
                                SizedBox(
                                  height: ScreenUtilHelper.setHeight(10),
                                ),
                                _noGoodDay(
                                    widget.lunisolarCalendarModel.result!.ji ??
                                        []),
                              ],
                            ),
                          ),
                          Column(
                            children: getWeekday().split('').map((char) {
                              return Container(
                                padding: EdgeInsets.only(
                                    left: ScreenUtilHelper.setWidth(20)),
                                child: Text(
                                  char,
                                  style: TextStyle(
                                      color: widget.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: ScreenUtilHelper.setSp(80)),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
              ExpandedComponent(
                children: [
                  AnimatedScale(
                    scale: isShowMask.value ? 1.0 : 0.6,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    child: ShakeWidget(
                      shakeConstant: ShakeRotateConstant1(),
                      duration: Duration(seconds: 5),
                      autoPlay: isShowMask.value ? false : true,
                      child: Container(
                        height: double.infinity,
                        padding:
                            EdgeInsets.only(left: ScreenUtilHelper.setWidth(2)),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtilHelper.setHeight(25)),
                              child: Row(
                                children: [
                                  Text(
                                    widget.weatherModel.result!.city ?? "",
                                    style: TextStyle(
                                        color: widget.color,
                                        fontSize: ScreenUtilHelper.setSp(40),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: ScreenUtilHelper.setWidth(2),
                                  ),
                                  Icon(
                                    IconFontIcons.icon_daohang,
                                    color: widget.color,
                                    size: ScreenUtilHelper.setSp(40),
                                  )
                                ],
                              ),
                            ),
                            Text(
                              "${widget.weatherModel.result!.temp}℃",
                              style: TextStyle(
                                  color: widget.color,
                                  fontSize: ScreenUtilHelper.setSp(130),
                                  fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Icon(
                                  WeatherIcon(
                                      widget.weatherModel.result!.weather ??
                                          ""),
                                  color: widget.color,
                                  size: ScreenUtilHelper.setSp(40),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                      widget.weatherModel.result?.weather ?? "",
                                      style: TextStyle(
                                          fontSize: ScreenUtilHelper.setSp(40),
                                          color: widget.color,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                "${widget.weatherModel.result!.templow}℃ / ${widget.weatherModel.result!.temphigh}℃",
                                style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScreenUtilHelper.setSp(50)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedScale(
                    scale: isShowMask.value ? 1.0 : 0.6,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOutQuart,
                    child: ShakeWidget(
                      shakeConstant: ShakeRotateConstant1(),
                      duration: Duration(seconds: 5),
                      autoPlay: isShowMask.value ? false : true,
                      child: Container(
                        padding:
                            EdgeInsets.only(left: ScreenUtilHelper.setWidth(2)),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtilHelper.setHeight(25)),
                              child: Row(
                                children: [
                                  Text(
                                    widget.weatherModel.result!.city ?? "",
                                    style: TextStyle(
                                        color: widget.color,
                                        fontSize: ScreenUtilHelper.setSp(35),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: ScreenUtilHelper.setWidth(2),
                                  ),
                                  Icon(
                                    IconFontIcons.icon_daohang,
                                    color: widget.color,
                                    size: ScreenUtilHelper.setSp(30),
                                  )
                                ],
                              ),
                            ),
                            Text(
                              "${widget.weatherModel.result!.temp}℃",
                              style: TextStyle(
                                  color: widget.color,
                                  fontSize: ScreenUtilHelper.setSp(66),
                                  fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Icon(
                                  WeatherIcon(
                                      widget.weatherModel.result!.weather ??
                                          ""),
                                  color: widget.color,
                                  size: ScreenUtilHelper.setSp(20),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                      widget.weatherModel.result?.weather ?? "",
                                      style: TextStyle(
                                          fontSize: ScreenUtilHelper.setSp(20),
                                          color: widget.color,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                "${widget.weatherModel.result!.templow}℃ / ${widget.weatherModel.result!.temphigh}℃",
                                style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: ScreenUtilHelper.setSp(20)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }

  String getWeekday() {
    // 获取当前日期
    DateTime now = DateTime.now();

    // weekday的值从1（星期一）到7（星期日）
    int weekdayIndex = now.weekday;

    // 创建一个列表来存储星期的名称
    List<String> weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

    // 根据weekdayIndex获取对应的星期名称
    String weekday =
        weekdays[weekdayIndex - 1]; // 因为weekdayIndex从1开始，而数组索引从0开始，所以需要减1

    return weekday;
  }

  String getFormattedDate() {
    // 获取当前日期
    DateTime now = DateTime.now();

    // 提取年、月、日
    // 格式化日期字符串，例如 "2023-09-17"
    String formattedDate =
        '${now.year}年${now.month.toString().padLeft(2, '0')}月';
    return formattedDate;
  }

  Widget _goodDay<T>(List<T> goodDayInfo) {
    List<Padding> textWidgets = goodDayInfo
        .sublist(0, 5)
        .map((item) => Padding(
              padding: EdgeInsets.fromLTRB(0, ScreenUtilHelper.setHeight(20),
                  ScreenUtilHelper.setWidth(10), 0),
              child: Text(
                item as String,
                style: TextStyle(
                    color: Colors.green, fontSize: ScreenUtilHelper.setSp(25)),
              ),
            ))
        .toList();

    return Row(
      children: textWidgets,
    );
  }

  Widget _noGoodDay<T>(List<T> noGoodDay) {
    List<Container> textWidgets = noGoodDay
        .sublist(0, 5)
        .map((item) => Container(
              padding: EdgeInsets.only(right: ScreenUtilHelper.setWidth(10.0)),
              child: Text(
                item as String,
                style: TextStyle(
                    color: widget.color, fontSize: ScreenUtilHelper.setSp(25)),
              ),
            ))
        .toList();

    return Row(
      children: textWidgets,
    );
  }

  void _changeMask(RxBool value) {
    isShowMask.value = !value.value;
  }

  void changeMask(int index) {
    if (selectedExpanded.value == index) {
      isShowMask.value = !isShowMask.value;
    } else {
      selectedExpanded.value = index;
      isShowMask.value = true;
    }
  }
}
