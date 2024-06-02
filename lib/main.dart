import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lock_screen_clock/mixins/date_helper_mixin.dart';
import 'package:lock_screen_clock/pages/SwiperWidget.dart';
import 'package:lock_screen_clock/util/ScreenUtilHelper.dart';
import 'package:lock_screen_clock/util/util.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:one_clock/one_clock.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import 'package:slide_popup_dialog_null_safety/slide_popup_dialog.dart'
    as slideDialog;
import 'package:switcher_xlive/switcher_xlive.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

import 'controller/HomePageController.dart';
import 'data/data.dart';
import 'model/LunisolarCalendar.dart';
import 'model/Weather.dart'; // 导入数学库

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
  Wakelock.enable();
  await SpUtils.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // 隐藏状态栏并进入全屏模式
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        ScreenUtil.init(context, designSize: const Size(390, 844));
      } else {
        ScreenUtil.init(context, designSize: const Size(844, 390));
      }

      return GetMaterialApp(
        title: '时钟小组件',
        initialRoute: '/',
        theme: ThemeData(
          fontFamily: 'PingFang',
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
            bodyMedium:
                TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
            displayLarge:
                TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            displayMedium:
                TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            // 可以根据需要添加更多的TextStyle
          ),
        ),
        getPages: [
          GetPage(name: "/swiperWidget", page: () => const SwiperContainer())
        ],
        routingCallback: (routing) {
          if (routing?.current == '/swiperWidget') {
            //隐藏系统通知栏和导航栏
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: []);
          } else {
            //恢复系统导航栏
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          }
        },
        home: const MyHomePage(),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, DateHelperMixin {
  //开启消息提醒
  RxBool isNotificationReminder = false.obs; //开启消息提醒
  RxBool isAWordDay = false.obs;
  //开启天气服务
  RxBool isWeatherAlarmEnabled = false.obs;
  //开关服务
  bool started = false;
  //获取定位
  String _locationMessage = "";
  ReceivePort port = ReceivePort();
  final MyHomePageController homePageController =
      Get.put(MyHomePageController());

  late WeatherModel weatherModel;
  late LunisolarCalendarModel lunisolarCalendarModel;

  final RxList<NotificationEvent> _log = <NotificationEvent>[].obs; //储存消息通知列表

  final RxBool _isSleepGoal = false.obs;
  final Rx<PickedTime> inBedTime = Rx<PickedTime>(PickedTime(h: 0, m: 0));
  final Rx<PickedTime> outBedTime = Rx<PickedTime>(PickedTime(h: 8, m: 0));

  final RxInt outBedTimeTimestampInSeconds = 0.obs; //开始时间《不含日期》
  final RxInt inBedTimeTimestampInSeconds = 0.obs; //结束时间《不含日期》
  final RxInt currentTimestampInSeconds = 0.obs; //结束时间《不含日期》

  final ClockTimeFormat _clockTimeFormat = ClockTimeFormat.twentyFourHours;
  final ClockIncrementTimeFormat _clockIncrementTimeFormat =
      ClockIncrementTimeFormat.fiveMin;
  Timer? _timer;

  var dataItems = [].obs;

  @override
  void initState() {
    super.initState();

    //初始化app数据
    initAppData();

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
    // if (!dataItems[1].buttonValue.value) {
    //   print("按钮关闭，服务启动失败");
    //    await NotificationsListener.stopService();
    //   return;
    // }

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
              color: const Color(0xFFF3F3F5),
              child: ListView(
                children: [
                  SizedBox(
                    height: ScreenUtilHelper.setHeight(50),
                  ),
                  _mainTitleClock(context),
                  SizedBox(
                    height: ScreenUtilHelper.setHeight(20),
                  ),
                  Obx(() => _mainListWidget(
                      "睡眠",
                      "开启后改时间段内，屏幕亮度将会有所降低，在结束时恢复，并自动开启天气闹钟。",
                      isWeatherAlarmEnabled.value,
                      (value) => _setWeatherAlarmEnabled(value!),
                      (value) => _showDialog(true),
                      true)),
                  Obx(() => _mainListWidget(
                      "沉浸式通知",
                      "开启后将在全屏显示时间时，沉浸式显示通知内容。",
                      isNotificationReminder.value,
                      (value) => _setNotificationReminder(value),
                      (value) => _showDialog(false),
                      false)),
                  Obx(() => _mainListWidget(
                      "每日一言",
                      "开启后将在全屏显示时间时，沉浸式显示通知内容。",
                      isAWordDay.value,
                      (value) => {_setAWordDay(value!)},
                      (value) => _showDialog(false),
                      false)),
                  // Obx(() => _mainListWidget(context, dataItems[1], 1))
                ],
                // children: dataItems.map<Widget>((element) => _mainListWidget(context, element.title, element.subTitle, element.onTap)).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Hero(
        tag: "swiper_container",
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            Get.toNamed("/swiperWidget");
          },
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.input),
        ),
      ),
    );
  }

  fetchWeather() async {
    WeatherModel model = await Weather.fetch();
    LunisolarCalendarModel models = await LunisolarCalendar.fetch(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    homePageController.weatherModel.value = model;
    homePageController.lunisolarCalendarModel.value = models;
  }

  _showDialog(bool value) {

    if (!value) {
      return;
    }

    showMaterialModalBottomSheet(
      useRootNavigator: true,
      backgroundColor: const Color(0xFFF3F3F5),
      context: context,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: ScreenUtilHelper.setHeight(20)),
            Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(260 / 2), // 设置圆角半径
                ),
                height: ScreenUtilHelper.setHeight(260),
                width: ScreenUtilHelper.setWidth(260),
                child: Obx(
                  () => TimePicker(
                      initTime: inBedTime.value,
                      endTime: outBedTime.value,
                      height: ScreenUtilHelper.setHeight(260),
                      width: ScreenUtilHelper.setWidth(260),
                      onSelectionChange: _updateLabels,
                      onSelectionEnd: (start, end, isDisableRange) => print(
                          'onSelectionEnd => init : ${start.h}:${start.m}, end : ${end.h}:${end.m}, isDisableRange: $isDisableRange'),
                      primarySectors: _clockTimeFormat.value,
                      secondarySectors: _clockTimeFormat.value * 2,
                      decoration: TimePickerDecoration(
                        baseColor: const Color.fromARGB(255, 197, 176, 176),
                        pickerBaseCirclePadding: 0.0,
                        sweepDecoration: TimePickerSweepDecoration(
                          pickerStrokeWidth: 15.0,
                          pickerColor: _isSleepGoal.value
                              ? const Color(0xFF3CDAF7)
                              : const Color(0xFFFF5252),
                        ),
                        initHandlerDecoration: TimePickerHandlerDecoration(
                          color: _isSleepGoal.value
                              ? const Color(0xFF3CDAF7)
                              : const Color(0xFFFF5252),
                          shape: BoxShape.circle,
                          radius: 12.0,
                          icon: const Icon(
                            Icons.power_settings_new_outlined,
                            size: 20.0,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        endHandlerDecoration: TimePickerHandlerDecoration(
                          color: _isSleepGoal.value
                              ? const Color(0xFF3CDAF7)
                              : const Color(0xFFFF5252),
                          shape: BoxShape.circle,
                          radius: 12.0,
                          icon: const Icon(
                            Icons.notifications_active_outlined,
                            size: 20.0,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                        primarySectorsDecoration: TimePickerSectorDecoration(
                          color: Colors.black,
                          width: 1.0,
                          size: 4.0,
                          radiusPadding: 25.0,
                        ),
                        secondarySectorsDecoration: TimePickerSectorDecoration(
                          color: const Color(0xFF3CDAF7),
                          width: 1.0,
                          size: 2.0,
                          radiusPadding: 25.0,
                        ),
                        clockNumberDecoration: TimePickerClockNumberDecoration(
                          defaultTextColor: _isSleepGoal.value
                              ? const Color(0xFF3CDAF7)
                              : const Color(0xFFFF5252),
                          defaultFontSize: 12.0,
                          scaleFactor: 2.0,
                          showNumberIndicators: true,
                          clockTimeFormat: _clockTimeFormat,
                          clockIncrementTimeFormat: _clockIncrementTimeFormat,
                        ),
                      )),
                )),
            Container(
              width: double.maxFinite,
              margin: EdgeInsets.fromLTRB(
                  ScreenUtilHelper.setWidth(20),
                  ScreenUtilHelper.setWidth(15),
                  ScreenUtilHelper.setWidth(20),
                  ScreenUtilHelper.setWidth(0)),
              padding: EdgeInsets.all(ScreenUtilHelper.setWidth(10.0)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF2F2F2),
                    offset: const Offset(4, 4),
                    blurRadius: ScreenUtilHelper.setWidth(20),
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Obx(() => Text(
                    _isSleepGoal.value ? "高于睡眠目标(>=8) 😇" : '低于睡眠目标(<=8) 😴',
                    style: TextStyle(
                      color: _isSleepGoal.value
                          ? const Color(0xFF3CDAF7)
                          : const Color(0xFFFF5252),
                      fontSize: ScreenUtilHelper.setSp(20),
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _timeWidget(
                      "开始时间",
                      inBedTime.value,
                      Icon(
                        Icons.notification_add_outlined,
                        size: ScreenUtilHelper.setSp(25),
                        color: _isSleepGoal.value
                            ? const Color(0xFF3CDAF7)
                            : const Color(0xFFFF5252),
                      )),
                  _timeWidget(
                      "结束时间",
                      outBedTime.value,
                      Icon(
                        Icons.notifications_active_outlined,
                        size: ScreenUtilHelper.setSp(25),
                        color: _isSleepGoal.value
                            ? const Color(0xFF3CDAF7)
                            : const Color(0xFFFF5252),
                      )),
                ],
              ),
            ),
            clickableButtonMethod(context, "确定", _addSleepAlarmClock)!,
          ],
        ),
      ),
      // backgroundColor: Colors.black,
    );
  }

  _mainListWidget(String title, String subTitle, bool values,
      Function(bool?) onTap, Function(bool) OnTap, bool isShow) {
    return InkWell(
        onTap: () => OnTap(isShow),
        child: Container(
          // width: ScreenUtilHelper.setWidth(400),
          margin: EdgeInsets.fromLTRB(
              ScreenUtilHelper.setWidth(20),
              ScreenUtilHelper.setHeight(10),
              ScreenUtilHelper.setWidth(20),
              ScreenUtilHelper.setHeight(10)),
          // padding: EdgeInsets.fromLTRB(ScreenUtilHelper.setWidth(0), ScreenUtilHelper.setHeight(5), ScreenUtilHelper.setWidth(0), ScreenUtilHelper.setHeight(5)),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(ScreenUtilHelper.setHeight(20))),
          child: ListTile(
            title: Text(title,
                style: TextStyle(
                    color: const Color(0xFF323031),
                    fontSize: ScreenUtilHelper.setSp(20),
                    fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: EdgeInsets.only(top: ScreenUtilHelper.setWidth(2)),
              child: Text(
                "$subTitle", // 使用 RxBool 的值
                style: TextStyle(fontSize: ScreenUtilHelper.setSp(14)),
              ),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: values
                          ? const Color.fromRGBO(71, 234, 139, 0.3)
                          : const Color.fromRGBO(255, 70, 80, 0.3),
                      offset: const Offset(5, 3),
                      blurRadius: 5,
                      spreadRadius: 0,
                    ),
                  ]),
              child: SwitcherXlive(
                value: values, // 使用 RxBool 的值
                onChanged: (value) => onTap(!values),
                activeColor: const Color(0xFF47EA8B),
                unActiveColor: const Color(0xFFFF4650),
                thumbColor: Colors.white,
              ),
            ),
          ),
        ));
  }

  _mainTitleClock(BuildContext context) {
    Map<String, dynamic> dateInfo = getCurrentDateInfo();
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ScreenUtilHelper.setWidth(300),
                height: ScreenUtilHelper.setHeight(300),
                alignment: Alignment.center, // 改为 Alignment.center
                decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF2F2F2),
                        offset: Offset(4, 4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    shape: BoxShape.circle),
              ),
              Container(
                alignment: Alignment.center, // 改为 Alignment.center
                width: ScreenUtilHelper.setWidth(280),
                height: ScreenUtilHelper.setHeight(280),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
                      offset: Offset(10, 10),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                  shape: BoxShape.circle,
                ),
                child: AnalogClock(
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
                  datetime: dateInfo["now"],
                  key: const GlobalObjectKey(3),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: ScreenUtilHelper.setHeight(10),
        ),
        Text(
          "${dateInfo['year']}-${dateInfo["month"]}-${dateInfo["day"]}  ${dateInfo["weekday"]}",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        )
      ],
    );
  }

  void _setNotificationReminder(bool? value) async {
    isNotificationReminder.value = value!;

    if (isNotificationReminder.value) {
      startListening();
    }

    SpUtils.setBool("isNotificationReminder", value);
  }

  void _updateLabels(
    PickedTime init,
    PickedTime end,
    isDisableRange,
  ) async {
    //获取设备是否能震动
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != null && hasVibrator) {
      Vibration.vibrate(duration: 10, amplitude: 120);
    }
    final baseDate = DateTime.now();
    final startTime =
        DateTime(baseDate.year, baseDate.month, baseDate.day, init.h, init.m);
    DateTime endTime =
        DateTime(baseDate.year, baseDate.month, baseDate.day, end.h, end.m);

    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(const Duration(days: 1));
    }

    final duration = endTime.difference(startTime);

    _isSleepGoal.value = duration.inHours >= 8;

    inBedTime.value = init;
    outBedTime.value = end;
  }

  ///底部睡眠时钟组件
  _timeWidget(String s, PickedTime time, Icon icon) {
    return Container(
      width: ScreenUtilHelper.setWidth(150),
      margin: EdgeInsets.fromLTRB(
          ScreenUtilHelper.setWidth(0),
          ScreenUtilHelper.setHeight(20),
          ScreenUtilHelper.setWidth(0),
          ScreenUtilHelper.setHeight(0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF2F2F2),
            offset: Offset(4, 4),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text(
              '${intl.NumberFormat('00').format(time.h)}:${intl.NumberFormat('00').format(time.m)}',
              style: TextStyle(
                color: _isSleepGoal.value
                    ? const Color(0xFF3CDAF7)
                    : const Color(0xFFFF5252),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ScreenUtilHelper.setHeight(15)),
            Text(
              s,
              style: TextStyle(
                color: _isSleepGoal.value
                    ? const Color(0xFF3CDAF7)
                    : const Color(0xFFFF5252),
                fontSize: ScreenUtilHelper.setSp(16),
              ),
            ),
            SizedBox(height: ScreenUtilHelper.setHeight(10)),
            icon,
          ],
        ),
      ),
    );
  }

  void _addSleepAlarmClock() {
    inBedTimeTimestampInSeconds.value =
        Utils().calculateTimestamp(Time(inBedTime.value.h, inBedTime.value.m));
    outBedTimeTimestampInSeconds.value = Utils()
        .calculateTimestamp(Time(outBedTime.value.h, outBedTime.value.m));

    isWeatherAlarmEnabled.value = !isWeatherAlarmEnabled.value;

    ///初始化app数据
    initAppData();

    SpUtils.setBool(
        "isWeatherAlarmEnabled", isWeatherAlarmEnabled.value); //开启天气时钟

    //调用方法本地存储睡眠的开始时间和结束时间
    _setInBedTime(inBedTimeTimestampInSeconds.value);
    _setOutBedTime(outBedTimeTimestampInSeconds.value);
    Navigator.of(context).pop();
  }

  Widget? clickableButtonMethod(
    BuildContext context,
    String text,
    VoidCallback onTap,
  ) {
    return InkWell(
      splashColor: Colors.transparent, // 禁用波纹颜色»»»»»»
      highlightColor: Colors.transparent, // 禁用高亮颜色
      onTap: onTap,
      child: Container(
        width: double.maxFinite,
        margin: EdgeInsets.fromLTRB(
            ScreenUtilHelper.setWidth(25),
            ScreenUtilHelper.setHeight(20),
            ScreenUtilHelper.setWidth(25),
            ScreenUtilHelper.setHeight(25)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.fromLTRB(
            ScreenUtilHelper.setWidth(15),
            ScreenUtilHelper.setHeight(15),
            ScreenUtilHelper.setWidth(15),
            ScreenUtilHelper.setHeight(15)),
        child: Center(
          child: Text(text,
              style: TextStyle(
                  fontSize: ScreenUtilHelper.setSp(15),
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _setInBedTime(int value) {
    SpUtils.setInt("inBedTime", value);
  }

  void _setOutBedTime(int value) {
    SpUtils.setInt("_outBedTime", value);
  }

  _setAWordDay(bool value) {
    isAWordDay.value = value;
    SpUtils.setBool("AWordDay", value);
  }

  void initAppData() {
    isNotificationReminder.value =
        SpUtils.getBool("isNotificationReminder") ?? false;
    isWeatherAlarmEnabled.value =
        SpUtils.getBool("isWeatherAlarmEnabled") ?? false;
    isAWordDay.value = SpUtils.getBool("AWordDay") ?? false;

    if (isNotificationReminder.value) {
      if (Platform.isAndroid) {
        ///监听系统通知事件
        initPlatformState();

        print("开始监听${isNotificationReminder.value}");

        ///开始监听通知栏列表
        startListening();
      }
    }

    if (isWeatherAlarmEnabled.value) {
      fetchWeather();
      outBedTimeTimestampInSeconds.value = SpUtils.getInt("_outBedTime") ?? 0;
      inBedTimeTimestampInSeconds.value = SpUtils.getInt("inBedTime") ?? 0;
      _startTimer();
    }

    if (isAWordDay.value) {}
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTimestampInSeconds.value = Utils()
          .calculateTimestamp(Time(DateTime.now().hour, DateTime.now().minute));

      if (currentTimestampInSeconds <= inBedTimeTimestampInSeconds.value) {
        print("进入夜间模式");
      } else if (currentTimestampInSeconds <=
          outBedTimeTimestampInSeconds.value) {
        print("进入后半夜夜间模式");
      } else {
        // print("推出夜间模式${outBedTimeTimestampInSeconds.value}");
      }

      // print("currentTimestampInSeconds---${currentTimestampInSeconds.value}");
    });
  }

  _setWeatherAlarmEnabled(bool value) {
    isWeatherAlarmEnabled.value = value;
    SpUtils.setBool("isWeatherAlarmEnabled", value);
  }
}
