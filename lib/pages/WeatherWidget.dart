import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_clock/pages/some_page.dart';
import 'package:flutter_screen_clock/util/util.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

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

  bool isGoodDayExpanded = false; // 控制"宜"的展开状态
  bool isNoDayExpanded = false; // 控制"忌"的展开状态
  double? _commonFontSize; // 用于存储共同的字体大小

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
                        children: [
                          Expanded(
                            flex: 90,
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    color: Colors.orange,
                                    alignment: Alignment.center,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        // 农历文本内容
                                        final nongliText = widget
                                                .lunisolarCalendarModel
                                                .result
                                                ?.nongli ??
                                            "";

                                        // 动态计算字体大小
                                        final double fontSize = math.min(
                                          constraints.maxWidth /
                                              nongliText.length, // 根据宽度计算
                                          constraints.maxHeight * 0.8, // 根据高度计算
                                        );

                                        return FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            nongliText,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: widget.color,
                                              fontSize: fontSize, // 动态字体大小
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 2, // 保持原样式
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final Day = DateTime.now()
                                            .day
                                            .toString()
                                            .padLeft(2, '0')
                                            .split('');

                                        return Container(
                                          height: constraints.maxHeight,
                                          // color: Colors.redAccent,  // 用于调试
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: Day.map<Widget>((char) {
                                              return Expanded(
                                                child: LayoutBuilder(
                                                  builder: (context,
                                                      charConstraints) {
                                                    // 计算最佳字体大小，同时考虑宽度和高度
                                                    double heightBasedSize =
                                                        charConstraints
                                                                .maxHeight *
                                                            1.4;
                                                    double widthBasedSize =
                                                        charConstraints
                                                                .maxWidth *
                                                            1.4;
                                                    // 取较小值确保完全适应空间
                                                    double fontSize = math.min(
                                                        heightBasedSize,
                                                        widthBasedSize);

                                                    return Container(
                                                      // color: Colors.blue.withOpacity(0.3),  // 用于调试
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        char,
                                                        style: TextStyle(
                                                          color: widget.color,
                                                          fontSize: fontSize,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              "PingFang Pro",
                                                          height: 1,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: ScreenUtilHelper.setHeight(10),
                                  ),
                                  _goodDay(widget
                                          .lunisolarCalendarModel.result?.yi ??
                                      []),
                                  SizedBox(
                                    height: ScreenUtilHelper.setHeight(10),
                                  ),
                                  _noGoodDay(widget
                                          .lunisolarCalendarModel.result?.ji ??
                                      []),
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width * 0.10,
                          //   height: MediaQuery.of(context).size.height * 0.8,
                          //   child: Container(
                          //     color: Colors.red,
                          //     child: LayoutBuilder(
                          //         builder: (context, constraints) {
                          //       final weekdayChars =
                          //           dateInfo['weekday'].split('');
                          //       // 减间距，增加可用空间
                          //       final double maxCharHeight =
                          //           (constraints.maxHeight -
                          //                   (weekdayChars.length - 1) * 1) /
                          //               weekdayChars.length;
                          //       // 增加字体大小比例
                          //       final double fontSize = math.min(
                          //           constraints.maxWidth * 1.2,
                          //           maxCharHeight * 1.0);
                          //
                          //       return Column(
                          //           mainAxisAlignment:
                          //               MainAxisAlignment.spaceBetween,
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.stretch,
                          //           children: weekdayChars.map<Widget>((char) {
                          //             return Container(
                          //                 alignment: Alignment.center,
                          //                 child: Text(
                          //                   char,
                          //                   style: TextStyle(
                          //                     color: widget.color,
                          //                     fontWeight: FontWeight.w600,
                          //                     fontSize: fontSize,
                          //                     height: 1.0,
                          //                   ),
                          //                 ));
                          //           }).toList());
                          //     }),
                          //   ),
                          // ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.10,
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: Container(
                              color: Colors.red,
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                final weekdayChars =
                                    dateInfo['weekday'].split('');
                                final double maxCharHeight =
                                    constraints.maxHeight / weekdayChars.length;
                                final double fontSize = math.min(
                                    constraints.maxWidth, maxCharHeight);

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: weekdayChars.map<Widget>((char) {
                                    return Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(
                                          char,
                                          style: TextStyle(
                                            color: widget.color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: fontSize, // 可动态调整
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }),
                            ),
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
    // 格式化日期字符串例如 "2023-09-17"
    String formattedDate =
        '${now.year}年${now.month.toString().padLeft(2, '0')}月';
    return formattedDate;
  }

  Widget _goodDay(List<String> goods) {
    final displayItems = isGoodDayExpanded ? goods : goods.take(5).toList();

    return Container(
      height: 40, // 给定固定高度
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "宜",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtilHelper.setSp(32), // 使用固定字号
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              displayItems.join('  '),
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.w600,
                fontSize: ScreenUtilHelper.setSp(32), // 使用相同字���
              ),
              overflow: TextOverflow.clip, // 直接隐藏溢出部分
            ),
          ),
        ],
      ),
    );
  }

  Widget _noGoodDay(List<String> bads) {
    final displayItems = isNoDayExpanded ? bads : bads.take(5).toList();

    return Container(
      height: 40, // 给定固定高度
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "忌",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtilHelper.setSp(32), // 使用相同字号
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              displayItems.join('  '),
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.w600,
                fontSize: ScreenUtilHelper.setSp(32), // 使用相同字号
              ),
              overflow: TextOverflow.ellipsis, // 处理文本溢出
            ),
          ),
        ],
      ),
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
