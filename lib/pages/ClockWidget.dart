
//生成日历小组件
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../util/ScreenUtilHelper.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}
class _ClockWidgetState extends State<ClockWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  late DateTime _focusedDay = DateTime.now(); // 添加focusedDay状态变量

  late DateTime _firstDayOfMonth;    //动态生成当前月份。
  late DateTime _lastDayOfMonth;  //动态生成当前月份。

  @override
  void initState() {
    super.initState();

    _updataDay();
    // 每秒更新一次时间
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {

      setState(() {
        _now = DateTime.now();
      });
    });
  }
  @override
  void dispose() {

    _timer.cancel(); // 取消计时器以避免内存泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch, // 让子组件在水平方向上填满整个 Column
          children: [
            Expanded( // 使用 Expanded 组件包装文本组件
              child:Container(
                // padding: const EdgeInsets.only(top: 20),
                child: Center(
                  child: TableCalendar(
                    //设置头部样式
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      formatButtonShowsNext: false,
                      leftChevronVisible: false, // 隐藏左侧按钮
                      rightChevronVisible: false, // 隐藏右侧按钮
                      titleCentered: true,
                      // headerMargin: EdgeInsets.only(bottom: 10.0),
                      titleTextStyle: TextStyle(
                        // fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4650),
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, color: Colors.white), // 设置字体大小
                      // weekendStyle: TextStyle(fontSize: 18), // 设置字体大小
                    ),
                    calendarStyle: const CalendarStyle(
                      // cellMargin: EdgeInsets.all(10),
                      todayDecoration: BoxDecoration(
                        color: Color(0xFFFF4650),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      weekendTextStyle: TextStyle(
                          color: Colors.white
                      ),
                    ),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    firstDay: _firstDayOfMonth, // 2024年5月1日
                    lastDay: _lastDayOfMonth, // 2024年5月31日
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay; // 更新focusedDay
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded( // 使用 Expanded 组件包装文本组件
              child: CustomPaint(
                painter: ClockPainter(context, _now),
                size: Size(ScreenUtilHelper.setWidth(400), ScreenUtilHelper.setHeight(400)), // Adjust size as needed
              ),
            ),
          ],
        )
      ),
    );
  }


  void _updataDay() {
    _firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    _lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
  }

}

//生成时钟小组件
class ClockPainter extends CustomPainter {
  final BuildContext context;
  final DateTime datetime;

  // 构造函数，需要传入BuildContext和DateTime
  ClockPainter(this.context, this.datetime);

  @override
  void paint(Canvas canvas, Size size) {
    // 计算中心点的坐标
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);

    // 计算时针、分针和秒针的长度
    double minHandLength = centerX * 0.7;
    double hourHandLength = centerX * 0.6;
    double secHandLength = centerX * 0.8;

    // 创建画分针的画笔
    Paint minHandPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    // 计算分针的角度
    double minDegrees = 360 / 60 * datetime.minute;
    // 计算分针的终点坐标
    double minX = centerX + minHandLength * cos(minDegrees * pi / 180);
    double minY = centerY + minHandLength * sin(minDegrees * pi / 180);
    // 画分针
    canvas.drawLine(center, Offset(minX, minY), minHandPaint);

    // 创建画时针的画笔
    Paint hourHandPaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    // 计算时针的角度
    double hourDegrees = 360 / 12 * (datetime.hour % 12) + datetime.minute / 60 * 30;
    // 计算时针的终点坐标
    double hourX = centerX + hourHandLength * cos(hourDegrees * pi / 180);
    double hourY = centerY + hourHandLength * sin(hourDegrees * pi / 180);
    // 画时针
    canvas.drawLine(center, Offset(hourX, hourY), hourHandPaint);

    // 创建画秒针的画笔
    Paint secHandPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    // 计算秒针的角度
    double secDegrees = 360 / 60 * datetime.second;
    // 计算秒针的终点坐标
    double secX = centerX + secHandLength * cos(radians(secDegrees - 90));
    double secY = centerY + secHandLength * sin(radians(secDegrees - 90));
    // 画秒针
    canvas.drawLine(center, Offset(secX, secY), secHandPaint);

    // 创建画刻度的画笔
    Paint dashPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // 定义刻度的总数和长度
    int totalDashes = 60;
    double longDashLength = 25; // 修改刻度线长度为原来的1.5倍
    double shortDashLength = 25; // 短刻度线的长度
    double dashSpace = size.width /2 - longDashLength;
    // 画每一个刻度
    for (int i = 0; i < totalDashes; i++) {
      // 计算每一个刻度的角度
      double min = 360 / totalDashes * i;
      // 计算每一个刻度的起点坐标
      double x1 = centerX + dashSpace * cos(radians(min - 90));
      double y1 = centerY + dashSpace * sin(radians(min - 90));
      // 如果是整点，则刻度线长一些
      double dashLength = i % 5 == 0 ? longDashLength : shortDashLength;
      if(i % 5 == 0) {
        dashPaint.strokeWidth = 3;
      }else{
        dashPaint.strokeWidth = 2;
      }

      // 计算每一个刻度的终点坐标
      double x2 = centerX + (dashSpace + dashLength) * cos(radians(min - 90));
      double y2 = centerY + (dashSpace + dashLength) * sin(radians(min - 90));
      // 画刻度
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), dashPaint);
    }

    // 准备画数字
    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    // 画每一个数字
    for (int i = 1; i <= 12; i++) {
      // 设置数字的样式
      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(
            color: Colors.white24,
            fontSize: 23,
            fontWeight: FontWeight.bold
        ),
      );
      // 这里我们需要让textPainter进行布局，否则我们无法获取到文字的宽度和高度
      textPainter.layout();

      // 计算每个数字的位置，这里我们让12个数字均匀的分布在表盘上
      double angle = 2 * pi / 12 * i;
      double x = centerX + (size.width / 2 - 40) * cos(angle - pi / 2) - textPainter.width / 2;
      double y = centerY + (size.height / 2 - 40) * sin(angle - pi / 2) - textPainter.height / 2;
      Offset offset = Offset(x, y);

      // 在计算出的位置上绘制文字
      textPainter.paint(canvas, offset);
    }
  }

  // 将角度转换为弧度
  double radians(double degree) {
    return degree * pi / 180;
  }

  // 返回true表示每次都需要重绘
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
