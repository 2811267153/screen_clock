import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lock_screen_clock/WeatherWidget.dart';
import 'package:lock_screen_clock/common/ListItem.dart';
import 'package:one_clock/one_clock.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:switcher_button/switcher_button.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart'
    as slideDialog;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:switcher_xlive/switcher_xlive.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

import 'ClockWidget.dart';
import 'data/data.dart';
import 'model/LunisolarCalendar.dart';
import 'model/Weather.dart'; // 导入数学库

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  await SpUtils.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // 隐藏状态栏并进入全屏模式
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return GetMaterialApp(
      title: '时钟小组件',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  //开启消息提醒
  RxBool isNotificationReminder = false.obs;
  //开启天气服务
  RxBool isWeatherAlarmEnabled = false.obs;
  //开关服务
  bool started = false;

  ReceivePort port = ReceivePort();

  late WeatherModel weatherModel;
  late LunisolarCalendarModel lunisolarCalendarModel;
  late List<Widget> itemWidget = <Widget>[ClockWidget()]; // 初始化itemWidget

  RxList<NotificationEvent> _log = <NotificationEvent>[].obs;//储存消息通知列表

  RxBool _isSleepGoal = false.obs;
  final Rx<PickedTime> inBedTime = Rx<PickedTime>(PickedTime(h: 0, m: 0));  
  final Rx<PickedTime> outBedTime = Rx<PickedTime>(PickedTime(h: 8, m: 0));

  ClockTimeFormat _clockTimeFormat = ClockTimeFormat.twentyFourHours;
  ClockIncrementTimeFormat _clockIncrementTimeFormat =
      ClockIncrementTimeFormat.fiveMin;

  var dataItems = <DataItem>[].obs;

  @override
  void initState() {
    super.initState();

    dataItems.value = [
      DataItem(
        title: "睡眠",
        buttonValue: isWeatherAlarmEnabled.value,
        subTitle: "开启后改时间段内，屏幕亮度将会有所降低，在结束时恢复，并自动开启天气闹钟。",
        onTap: ({required String title, required String subTitle}) {
          isWeatherAlarmEnabled.value = !isWeatherAlarmEnabled.value; // 更新 RxBool 的值
          _showDialog();
        },
      ),
      DataItem(
        title: "沉浸式通知",
        subTitle: "开启后将在全屏显示时间时，沉浸式显示通知内容。",
        buttonValue: isNotificationReminder.value,
        onTap: ({required String title, required String subTitle}) {
          _setNotificationReminder(!isNotificationReminder.value);
        },
      ),
    ];
    if (Platform.isAndroid)  {
      ///监听系统通知事件
      initPlatformState();
    }

    _getNotificationReminder();
    _getWeatherAlarmEnabled();

    // 监听页面发生变化
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除观察者
    super.dispose();
  }

  //监听程序进入前后台的状态改变的方法
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      var hasPermission = (await NotificationsListener.hasPermission) ?? false;
      _setNotificationReminder(hasPermission);
    }
  }

  void onData(NotificationEvent event) {
    print("----evevnt${event}");

    event.getFull().then((value) => print(value));
    _log.add(event);
  }

  @pragma(
      'vm:entry-point') // prevent dart from stripping out this function on release build in Flutter 3.x
  static void _callback(NotificationEvent evt) {
    final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  Future<void> initPlatformState() async {
    NotificationsListener.initialize(callbackHandle: _callback);

    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping("_listener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");
    port.listen((message) => onData(message));

    var isRunning = (await NotificationsListener.isRunning) ?? false;

    setState(() {
      started = isRunning;
    });
  }

  void startListening() async {
    print("开始监听");
    var hasPermission = (await NotificationsListener.hasPermission) ?? false;
    if (!hasPermission) {
      NotificationsListener.openPermissionSettings();
      return;
    }
    if (!dataItems[1].buttonValue.value) {
      print("按钮关闭，服务启动失败");
       await NotificationsListener.stopService();
      return;
    }

    var isRunning = (await NotificationsListener.isRunning) ?? false;

    if (!isRunning) {
      await NotificationsListener.startService(
          foreground: false,
          title: "Listener Running",
          description: "Welcome to having me");
    }

    setState(() {
      started = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // body: _swiperContainer(context, itemWidget),
      body: Stack(
        children: [
          MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: Container(
              color: Color(0xFFF3F3F5),
              child: Column(
                children: [
                  _mainTitleClock(context),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(() => _mainListWidget(context, dataItems.value[0], 0)),
                  Obx(() => _mainListWidget(context, dataItems[1], 1))
                ],
                // children: dataItems.map<Widget>((element) => _mainListWidget(context, element.title, element.subTitle, element.onTap)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  fetchWeather() async {
    WeatherModel model = await Weather.fetch();

    LunisolarCalendarModel models = await LunisolarCalendar.fetch(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    setState(() {
      weatherModel = model; // 将获取的数据赋值给 weatherherModel
      lunisolarCalendarModel = models;
      itemWidget.add(WeatherWidget(
          weatherModel: weatherModel,
          lunisolarCalendarModel: lunisolarCalendarModel)); // 在这里构建itemWidget
    });
  }

  _showDialog() {
    
    slideDialog.showSlideDialog(
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(260 / 2), // 设置圆角半径
            ),
            height: 260,
            width: 260,
            child: Obx(() => TimePicker(
                initTime:  inBedTime.value,
                endTime:   outBedTime.value,
                height: 260.0,
                width: 260.0,
                onSelectionChange: _updateLabels,
                onSelectionEnd: (start, end, isDisableRange) => print(
                    'onSelectionEnd => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRange: $isDisableRange'),
                primarySectors: _clockTimeFormat.value,
                secondarySectors: _clockTimeFormat.value * 2,
                decoration: TimePickerDecoration(
                  baseColor: Color(0xFF1F2633),
                  pickerBaseCirclePadding: 15.0,
                  sweepDecoration: TimePickerSweepDecoration(
                    pickerStrokeWidth: 30.0,
                    pickerColor:
                        _isSleepGoal.value ? Color(0xFF3CDAF7) : Colors.white,
                    showConnector: true,
                  ),
                  initHandlerDecoration: TimePickerHandlerDecoration(
                    color: Color(0xFF141925),
                    shape: BoxShape.circle,
                    radius: 12.0,
                    icon: Icon(
                      Icons.power_settings_new_outlined,
                      size: 20.0,
                      color: Color(0xFF3CDAF7),
                    ),
                  ),
                  endHandlerDecoration: TimePickerHandlerDecoration(
                    color: Color(0xFF141925),
                    shape: BoxShape.circle,
                    radius: 12.0,
                    icon: Icon(
                      Icons.notifications_active_outlined,
                      size: 20.0,
                      color: Color(0xFF3CDAF7),
                    ),
                  ),
                  primarySectorsDecoration: TimePickerSectorDecoration(
                    color: Colors.white,
                    width: 1.0,
                    size: 4.0,
                    radiusPadding: 25.0,
                  ),
                  secondarySectorsDecoration: TimePickerSectorDecoration(
                    color: Color(0xFF3CDAF7),
                    width: 1.0,
                    size: 2.0,
                    radiusPadding: 25.0,
                  ),
                  clockNumberDecoration: TimePickerClockNumberDecoration(
                    defaultTextColor: Colors.white,
                    defaultFontSize: 12.0,
                    scaleFactor: 2.0,
                    showNumberIndicators: true,
                    clockTimeFormat: _clockTimeFormat,
                    clockIncrementTimeFormat: _clockIncrementTimeFormat,
                  ),
                )),)
          ),
          Container(
             width: 300.0,
             margin: EdgeInsets.only(top: 15),
             padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFF1F2633),
                borderRadius: BorderRadius.circular(25.0),
              ),
            child: Obx(() =>  Text( _isSleepGoal.value
                    ? "高于睡眠目标(>=8) 😇"
                    : '低于睡眠目标(<=8) 😴',style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),)),
          ),
          Obx(() => 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _timeWidget(
                  "开始时间",
                  inBedTime.value,
                  Icon(
                    Icons.notification_add_outlined,
                    size: 25,
                    color: Color(0xFF3CDAF7),
                  )),
              _timeWidget(
                  "结束时间",
                  outBedTime.value,
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 25,
                    color: Color(0xFF3CDAF7),
                  )),
            ],
          ),
          )
        ],
      ),
      barrierColor: Colors.black.withOpacity(0.7),
      pillColor: Colors.red,
      backgroundColor: Color(0xFFF2F8FE),
      // backgroundColor: Colors.black,
    );
  }

  _mainListWidget(BuildContext context, DataItem dataItem, int i) {

    return  InkWell(
          onTap: () => dataItem.onTap(title: dataItem.title, subTitle: dataItem.subTitle), // 使用 DataItem 的 onTap 回调, // 处理点击事件
          child: Container(
            width: 400,
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
            ),
            child:  Obx(() => ListTile(
              title: Text(dataItem.title, style: TextStyle(color: Color(0xFF323031), fontWeight: FontWeight.bold)),
              subtitle: Text(
                "${dataItem.subTitle}--${dataItem.buttonValue.value}", // 使用 RxBool 的值
                style: TextStyle(fontSize: 12),
              ),
              trailing: Container(
                decoration:  BoxDecoration(
                  borderRadius: BorderRadius.circular(20),   
                  boxShadow: [     BoxShadow(
                    color: dataItems[i].buttonValue.value ? Color.fromRGBO(71,234,139, 0.3) : Color.fromRGBO(255,70,80, 0.3),
                    offset: Offset(5, 3),
                    blurRadius: 5,
                    spreadRadius: 0,
                  ),]
                ),
                child: SwitcherXlive(
                  value: dataItem.buttonValue.value, // 使用 RxBool 的值
                  onChanged: (value) {
                    dataItem.onTap(title: dataItem.title, subTitle: dataItem.subTitle);
                  },
                  activeColor: Color(0xFF47EA8B),
                  unActiveColor: Color(0xFFFF4650),
                  thumbColor: Colors.white,
                ),
              ),
            )),
          ),
        );
  }

  _mainTitleClock(BuildContext context) {

    // 获取当前日期
    DateTime now = DateTime.now();
    // 提取年、月、日
    int year = now.year;
    int month = now.month; // 注意：月份是从1开始的，不是从0开始的
    int day = now.day;

    // weekday的值从1（星期一）到7（星期日）
    int weekdayIndex = now.weekday;

    // 创建一个列表来存储星期的名称
    List<String> weekdays = [
      '星期一',
      '星期二',
      '星期三',
      '星期四',
      '星期五',
      '星期六',
      '星期日',
    ];

    // 根据weekdayIndex获取对应的星期名称
    String weekday = weekdays[weekdayIndex - 1];

    return Column(
      children: [
        AnalogClock(
          decoration: const BoxDecoration(
             color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
              offset: Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          shape: BoxShape.circle),
          width: 300.0,
          height: 300,
          isLive: true,
          hourHandColor: Colors.black,
          minuteHandColor: Colors.black,
          showSecondHand: true,
          numberColor: Colors.black87,
          showNumbers: true,
          showAllNumbers: false,
          textScaleFactor: 1.4,
          showTicks: false,
          showDigitalClock: false,
          datetime: DateTime.now(),
           key: const GlobalObjectKey(3),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "${year}-${month}-${day}  ${weekday}",
          style: TextStyle(fontSize: 20),
        )
      ],
    );
  }

  void _getNotificationReminder() async {
     isNotificationReminder.value =
          SpUtils.getBool("isNotificationReminder") ?? false;

     dataItems[1].buttonValue.value =  SpUtils.getBool("isNotificationReminder") ?? false;

    if (isNotificationReminder.value && Platform.isAndroid) {
      print("开始监听${isNotificationReminder.value}");
      ///开始监听通知栏列表
      startListening();
    }
  }

  void _setNotificationReminder(bool value) async {
    isNotificationReminder.value = value;
    dataItems[1].buttonValue.value =  value;

    var hasPermission = (await NotificationsListener.hasPermission) ?? false;

    if (dataItems[1].buttonValue.value && hasPermission) {
      startListening();
    }

    SpUtils.setBool("isNotificationReminder", value);
    print("_setNotificationReminder${ dataItems[1].buttonValue.value}");

  }

  ///获取天气信息
  void _getWeatherAlarmEnabled() async {

    isWeatherAlarmEnabled.value = SpUtils.getBool("isWeatherAlarmEnabled") ?? false;

    if (isWeatherAlarmEnabled.value) {
      ///发送网络数据
      fetchWeather();
    }
  }

  void _setWeatherAlarmEnabled(bool value) async {
    isNotificationReminder.value = value;

    SpUtils.setBool("isWeatherAlarmEnabled", value);
    print("isWeatherAlarmEnabled${value}");
  }

  void _updateLabels(PickedTime init, PickedTime end, isDisableRange) async{

    //获取设备是否能震动
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != null && hasVibrator ) {
      
      Vibration.vibrate(duration: 10, amplitude: 120);
    }
    final baseDate = DateTime.now();
    final startTime =
        DateTime(baseDate.year, baseDate.month, baseDate.day, init.h, init.m);
    DateTime endTime =
        DateTime(baseDate.year, baseDate.month, baseDate.day, end.h, end.m);

    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(Duration(days: 1));
    }

    final duration = endTime.difference(startTime);

    _isSleepGoal.value = duration.inHours >= 8;

    inBedTime.value = init;
    outBedTime.value = end;
  }

  ///底部睡眠时钟组件
  _timeWidget(String s, PickedTime time, Icon icon) {

    return Container(
      width: 150.0,
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Color(0xFF1F2633),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
                 Text(
              '${intl.NumberFormat('00').format(time.h)}:${intl.NumberFormat('00').format(time.m)}',
              style: TextStyle(
                color: Color(0xFF3CDAF7),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              '$s',
              style: TextStyle(
                color: Color(0xFF3CDAF7),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            icon,
          ],
        ),
      ),
    );
  }

}

///轮播组件
_swiperContainer(BuildContext context, List<Widget> itemWidget) {
  return Container(
    padding: EdgeInsets.only(left: MediaQuery.of(context).padding.right),
    color: Colors.black,
    child: Swiper(
      autoplay: true,
      duration: 500,
      autoplayDelay: 120000,
      itemBuilder: (BuildContext context, int index) {
        return itemWidget[index];
      },
      transformer: ScaleAndFadeTransformer(scale: 0.7),
      itemCount: itemWidget.length,
    ),
  );
}
