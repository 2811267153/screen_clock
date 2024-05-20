import 'package:flutter/material.dart';
import 'package:lock_screen_clock/common/MyIcon.dart';
import 'package:lock_screen_clock/model/LunisolarCalendar.dart';
import 'package:lock_screen_clock/model/Weather.dart';
import 'package:lock_screen_clock/weather_icons.dart';

class WeatherWidget extends StatefulWidget{

  final WeatherModel weatherModel;
  final LunisolarCalendarModel lunisolarCalendarModel;

  const WeatherWidget({super.key, required this.weatherModel, required this.lunisolarCalendarModel});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {

  @override
  Widget build(BuildContext context) {
      return Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(getFormattedDate(), style: TextStyle(color: Colors.red[400], fontSize: 70),),
                    ),
                  ],
                ),
                Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 2.0,color: Colors.white38, )
                      ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [

                              Text(widget.lunisolarCalendarModel.result!.nongli ?? "",style: TextStyle(color: Colors.red, fontSize: 20)),
                              SizedBox(height: 2,),
                              Text(DateTime.now().day.toString().padLeft(2, '0'),style: TextStyle(color: Colors.red, fontSize: 190, height: 0.8,  letterSpacing: 0.9,  )),
                              _goodDay(widget.lunisolarCalendarModel.result!.yi ?? []),
                              SizedBox(height: 4,),
                              _noGoodDay(widget.lunisolarCalendarModel.result!.ji ?? []),
                            ],
                          ),
                        )),
                    Column(
                      children:  getWeekday().split('').map((char) {
                        return Container(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            char,
                            style: TextStyle(color: Colors.red, fontSize: 60),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(widget.weatherModel.result!.city ?? "", style: TextStyle(color: Colors.red, fontSize: 55, fontWeight: FontWeight.bold),),
                  ),
                Text(
                "${widget.weatherModel.result!.temp}℃", style: TextStyle(color: Colors.red, fontSize: 105),),
                Row(
                  children: [
                    Icon(getWeatherIcon(widget.weatherModel.result!.weather ?? ""), color: Colors.red, size: 60,),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(widget.weatherModel.result?.weather ?? "",  style: TextStyle(fontSize: 40, color: Colors.red),),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text("${widget.weatherModel.result!.templow}℃ / ${widget.weatherModel.result!.temphigh}℃", style: TextStyle(color: Colors.red, fontSize: 40),),
                )

              ],
            ),
          )
        ],
      );
  }
  // 获取天气对应的图标
  IconData getWeatherIcon(String weatherCondition) {

    return weatherIconMap[weatherCondition] ?? IconFontIcons.iconWeizhi; // 默认图标为未知天气
  }

  String getWeekday() {
    // 获取当前日期
    DateTime now = DateTime.now();

    // weekday的值从1（星期一）到7（星期日）
    int weekdayIndex = now.weekday;

    // 创建一个列表来存储星期的名称
    List<String> weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];

    // 根据weekdayIndex获取对应的星期名称
    String weekday = weekdays[weekdayIndex - 1]; // 因为weekdayIndex从1开始，而数组索引从0开始，所以需要减1

    return weekday;
  }

  String getFormattedDate() {
    // 获取当前日期
    DateTime now = DateTime.now();

    // 提取年、月、日
    int year = now.year;
    int month = now.month; //月份是从1开始的，不是从0开始的

    // 格式化日期字符串，例如 "2023-09-17"
    // String formattedDate = '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    String formattedDate = '${year}-${month.toString().padLeft(2, '0')}';

    return formattedDate;
  }

  Widget _goodDay<T> ( List<T> goodDayInfo) {

    List<Padding> textWidgets = goodDayInfo.sublist(0, 5).map((item) => Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Text(item as String, style: TextStyle(color: Colors.green, fontSize: 15),),
    )).toList();

    return Row(
      children: textWidgets,
    );
  }

  Widget _noGoodDay <T> ( List<T> noGoodDay) {

    List<Container> textWidgets = noGoodDay.sublist(0, 5).map((item) => Container(
      padding: const EdgeInsets.only(right: 10.0),
      child: Text(item as String, style: TextStyle(color: Colors.red, fontSize: 15),),
    )).toList();

    return Row(
      children: textWidgets,
    );
  }
}