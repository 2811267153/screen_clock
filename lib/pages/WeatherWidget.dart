import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:get/get.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

import '../common/MyIcon.dart';
import '../common/ShakeAnimationWidget.dart';
import '../mixins/date_helper_mixin.dart';
import '../model/LunisolarCalendar.dart';
import '../model/Weather.dart';
import '../util/ScreenUtilHelper.dart';
import '../util/weather_icons.dart';

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
    with SingleTickerProviderStateMixin, DateHelperMixin {
  RxBool isShowMask = true.obs;
  final selectedExpanded = RxnInt();

  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  late List<Calendar> _calendars;
  Calendar? _selectedCalendar;
  List<Event>? _events;

  final todoList = [];

  double _viewportFraction = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///请求日历权限
    _retrieveCalendars();

    _retrieveEvents();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> dateInfo = getCurrentDateInfo();
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
                                        widget.lunisolarCalendarModel.result?.nongli ?? "",
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
                                      1.2, 1.0, 1.0), // 调整拉伸比例
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
                                    widget.lunisolarCalendarModel.result?.yi ??
                                        []),
                                SizedBox(
                                  height: ScreenUtilHelper.setHeight(10),
                                ),
                                _noGoodDay(
                                    widget.lunisolarCalendarModel.result?.ji ??
                                        []),
                              ],
                            ),
                          ),
                          Column(
                            children: dateInfo['weekday']
                                .split('')
                                .map<Widget>((char) {
                              return Container(
                                padding: EdgeInsets.only(
                                    left: ScreenUtilHelper.setWidth(15)),
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
                  ),
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
                        padding: EdgeInsets.only(
                            left: ScreenUtilHelper.setWidth(20)),
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
                                    widget.weatherModel.result?.city ?? "",
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
                              "${widget.weatherModel.result?.temp}℃",
                              style: TextStyle(
                                  color: widget.color,
                                  fontSize: ScreenUtilHelper.setSp(120),
                                  fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Icon(
                                  WeatherIcon(
                                      widget.weatherModel.result?.weather ??
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
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(
                                "${widget.weatherModel.result?.templow}℃ / ${widget.weatherModel.result?.temphigh}℃",
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

                      ///如果isShowMask就打开抖动，提醒用户可以编辑组件内容
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "今天",
                                    style: TextStyle(
                                        color: widget.color,
                                        fontSize: ScreenUtilHelper.setSp(35),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: ScreenUtilHelper.setWidth(2),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: ScreenUtilHelper.setWidth(20)),
                                    child: Text(
                                      todoList.length.toString(),
                                      style: TextStyle(
                                        color: widget.color,
                                        fontSize: ScreenUtilHelper.setSp(35),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            _buildTodoList(),
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

    List<T> itemToShow = goodDayInfo.length >= 5 ? goodDayInfo.sublist(0, 5) : goodDayInfo;
    List<Padding> textWidgets = itemToShow
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
    // 判断列表长度，如果大于5则截取前5个元素，否则不做截取
    List<T> itemsToShow = noGoodDay.length >= 5 ? noGoodDay.sublist(0, 5) : noGoodDay;

    // 将列表元素映射为Widget
    List<Container> textWidgets = itemsToShow
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

  _buildTodoList() {
    if (todoList.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: ScreenUtilHelper.setHeight(20)),
        child: Text(
          "没有提醒事项",
          style: TextStyle(
              color: Color.fromARGB(131, 255, 255, 255),
              fontSize: ScreenUtilHelper.setSp(35)),
        ),
      );
    }

    return Container(
      child: Text("DATA"),
    );
  }

  ///请求权限并获取日历
  Future<void> _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess &&
          permissionsGranted.data != null &&
          !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess ||
            permissionsGranted.data == null ||
            !permissionsGranted.data!) {
          return;
        }
      }

      if (permissionsGranted.isSuccess &&
          permissionsGranted.data != null &&
          permissionsGranted.data!) {
        final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
        setState(() {
          _calendars = calendarsResult.data as List<Calendar>;

          print("_calendars---${_calendars}");
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _retrieveEvents() async {
    if (_selectedCalendar == null) return;

    final startDate = DateTime.now().subtract(Duration(days: 30));
    final endDate = DateTime.now().add(Duration(days: 30));
    final retrieveEventsParams =
        RetrieveEventsParams(startDate: startDate, endDate: endDate);
    final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
        _selectedCalendar?.id, retrieveEventsParams);
    setState(() {
      _events = eventsResult?.data;
    });

    print("_events--${_events}");
  }
}
