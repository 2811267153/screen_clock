import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_clock/pages/some_page.dart';
import 'package:flutter_screen_clock/util/util.dart';
import 'package:get/get.dart';

import '../common/MyIcon.dart';
import '../common/ShakeAnimationWidget.dart';
import '../mixins/date_helper_mixin.dart';
import '../model/LunisolarCalendar.dart';
import '../model/Weather.dart';
import '../services/todo_list.dart';
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

  final ToDoListService controller = Get.put(ToDoListService());

  final todoList = [];

  double _viewportFraction = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //
    // ///请求日历权限
    // _retrieveCalendars();
    //
    // _retrieveEvents();
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
                                        widget.lunisolarCalendarModel.result
                                                ?.nongli ??
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
                  Container(
                    height: double.infinity,
                    padding:
                        EdgeInsets.only(left: ScreenUtilHelper.setWidth(20)),
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
                                  widget.weatherModel.result?.weather ?? ""),
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
                  Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  controller.events.length.toString(),
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
                  SomePage(
                    color: widget.color,
                  )
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
    List<T> itemToShow =
        goodDayInfo.length >= 5 ? goodDayInfo.sublist(0, 5) : goodDayInfo;
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
    List<T> itemsToShow =
        noGoodDay.length >= 5 ? noGoodDay.sublist(0, 5) : noGoodDay;

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

  _buildTodoList() {
    // print("controller${controller.events[0].title}");
    if (controller.events.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: ScreenUtilHelper.setHeight(20)),
        child: Text(
          "没有提醒事项",
          style: TextStyle(
              color: Color.fromARGB(131, 255, 255, 255),
              fontSize: ScreenUtilHelper.setSp(35)),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            final eventStart = Utils().formatTimeToHour(event.start);
            final eventEnd = Utils().formatTimeToHour(event.end);
            return Row(
              children: [
                Stack(
                  children: [
                    Container(
                      height: ScreenUtilHelper.setWidth(90),
                      margin: EdgeInsets.only(
                        top: ScreenUtilHelper.setWidth(20),
                        left: ScreenUtilHelper.setWidth(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: ScreenUtilHelper.setWidth(10),
                            ),
                            child: Text(
                                eventStart == "00:00" && eventEnd == "00:00"
                                    ? "全天事件"
                                    : "$eventStart-$eventEnd",
                                style: TextStyle(
                                  fontSize: ScreenUtilHelper.setSp(50),
                                  color: widget.color,
                                  height: 0.7,
                                )),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtilHelper.setWidth(10)),
                            child: Text(event.title!,
                                style: TextStyle(
                                  fontSize: ScreenUtilHelper.setSp(50),
                                  color: widget.color,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        child: Container(
                      margin:
                          EdgeInsets.only(top: ScreenUtilHelper.setWidth(20)),
                      width: ScreenUtilHelper.setWidth(10),
                      height: ScreenUtilHelper.setWidth(90),
                      decoration: BoxDecoration(
                          color: widget.color,
                          borderRadius: BorderRadius.circular(
                              ScreenUtilHelper.setWidth(20))),
                    ))
                  ],
                ),
                SizedBox(width: ScreenUtilHelper.setWidth(10))
              ],
            );
          },
        ),
      );
    }
  }
}
