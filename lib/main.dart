import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_clock/services/todo_list.dart';
import 'package:flutter_screen_clock/util/nativeToast.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:one_clock/one_clock.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';

import 'package:switcher_xlive/switcher_xlive.dart';
import 'package:vibration/vibration.dart';

import 'controller/HomePageController.dart';
import 'data/data.dart';
import 'mixins/date_helper_mixin.dart';
import 'model/LunisolarCalendar.dart';
import 'model/Weather.dart';
import 'pages/SwiperWidget.dart';
import 'services/notification_service.dart';
import 'util/ScreenUtilHelper.dart';
import 'util/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(NotificationService());
  Get.put(ToDoListService());

  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
  await SpUtils.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
        getPages: [
          GetPage(name: "/swiperWidget", page: () => const SwiperContainer())
        ],
        routingCallback: (routing) {
          if (routing?.current == '/swiperWidget') {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: []);
          } else {
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
  RxBool isMasterSwitchOn = false.obs;
  RxBool isNotificationReminder = false.obs;
  RxBool isAWordDay = false.obs;
  RxBool isWeatherAlarmEnabled = false.obs;

  final MyHomePageController homePageController =
      Get.put(MyHomePageController());

  late WeatherModel weatherModel;
  late LunisolarCalendarModel lunisolarCalendarModel;

  final RxBool _isSleepGoal = false.obs;
  final Rx<PickedTime> inBedTime = Rx<PickedTime>(PickedTime(h: 0, m: 0));
  final Rx<PickedTime> outBedTime = Rx<PickedTime>(PickedTime(h: 8, m: 0));

  final RxInt outBedTimeTimestampInSeconds = 0.obs;
  final RxInt inBedTimeTimestampInSeconds = 0.obs;
  final RxInt currentTimestampInSeconds = 0.obs;

  final ClockTimeFormat _clockTimeFormat = ClockTimeFormat.twentyFourHours;
  final ClockIncrementTimeFormat _clockIncrementTimeFormat =
      ClockIncrementTimeFormat.fiveMin;
  Timer? _timer;

  var dataItems = [].obs;

  static const platform =
      MethodChannel('com.example.flutter_screen_clock/master_switch');

  @override
  void initState() {
    super.initState();
    initAppData();
    WidgetsBinding.instance.addObserver(this);

    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'getMasterSwitchState':
          return isMasterSwitchOn.value;
        default:
          throw PlatformException(
            code: 'NotImplemented',
            message: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  _buildSettingsPanel(),
                ],
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
                  borderRadius: BorderRadius.circular(260 / 2),
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
    );
  }

  _mainListWidget(String title, String subTitle, bool values,
      Function(bool?) onTap, Function(bool) OnTap, bool isShow) {
    return InkWell(
        onTap: () => OnTap(isShow),
        child: Container(
          margin: EdgeInsets.fromLTRB(
              ScreenUtilHelper.setWidth(20),
              ScreenUtilHelper.setHeight(10),
              ScreenUtilHelper.setWidth(20),
              ScreenUtilHelper.setHeight(10)),
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
                subTitle,
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
                value: values,
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
                alignment: Alignment.center,
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
                alignment: Alignment.center,
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

  /// 设置通知提醒开关
  /// @param value 是开启通知提醒
  _setNotificationReminder(bool value) async {
    if (value && Platform.isAndroid) {
      await _checkAndStartNotificationService();
    } else {
      isNotificationReminder.value = false;
      SpUtils.setBool("isNotificationReminder", false);
      NotificationService.instance.stopListening();
    }
  }

  /// 初始化应用数据
  Future<void> initAppData() async {
    await SpUtils.getInstance();

    // 从本地存储读取主开关状态
    bool savedState = SpUtils.getBool("isMasterSwitchOn") ?? false;
    isMasterSwitchOn.value = savedState;

    // 如果主开关是开启状态，确保原生端也同步更新状态
    if (savedState) {
      const platform =
          MethodChannel('com.example.flutter_screen_clock/master_switch');
      try {
        // 更新原生端状态
        await platform.invokeMethod('updateMasterSwitch', {'isOn': true});
        // 确保锁屏功能启用
        await platform.invokeMethod('enableLockScreen');
      } catch (e) {
        print("Error initializing master switch state: $e");
      }
    }

    // 只有在总开关开启时才加载和启用其他开关状态
    if (isMasterSwitchOn.value) {
      isNotificationReminder.value =
          SpUtils.getBool("isNotificationReminder") ?? false;
      isWeatherAlarmEnabled.value =
          SpUtils.getBool("isWeatherAlarmEnabled") ?? false;
      isAWordDay.value = SpUtils.getBool("AWordDay") ?? false;

      // 如果通知提醒已开启，检查权限
      if (isNotificationReminder.value && Platform.isAndroid) {
        _checkAndStartNotificationService();
      }

      // 如果天气闹钟已开启，初始化相关数据
      if (isWeatherAlarmEnabled.value) {
        fetchWeather();
        outBedTimeTimestampInSeconds.value = SpUtils.getInt("_outBedTime") ?? 0;
        inBedTimeTimestampInSeconds.value = SpUtils.getInt("inBedTime") ?? 0;
        _startTimer();
      }
    }
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

    if (value) {
      fetchWeather();
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  // 添加一个透明度包装组件
  Widget _buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool enabled,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5, // 禁用时降低透明度
      child: AbsorbPointer(
        // 禁用时阻止触摸事件
        absorbing: !enabled,
        child: SwitcherXlive(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // 添加总开关控制方法
  void _setMasterSwitch(bool value) async {
    const platform =
        MethodChannel('com.example.flutter_screen_clock/master_switch');
    try {
      await platform.invokeMethod('updateMasterSwitch', {'isOn': value});
      isMasterSwitchOn.value = value;
      await SpUtils.setBool('isMasterSwitchOn', value);

      if (value) {
        await platform.invokeMethod('enableLockScreen');
      } else {
        await platform.invokeMethod('disableLockScreen');
      }
    } catch (e) {
      print('Error updating master switch: $e');
    }
  }

  // 修改设置界面的构建
  Widget _buildSettingsPanel() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            title: const Text("总开关",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            trailing: Obx(() => SwitcherXlive(
                  value: isMasterSwitchOn.value,
                  onChanged: _setMasterSwitch,
                  activeColor: const Color(0xFF47EA8B),
                  unActiveColor: const Color(0xFFFF4650),
                  thumbColor: Colors.white,
                )),
          ),
        ),

        ///_setMasterSwitch
        // 通知提醒开关
        Obx(() => Opacity(
              opacity: isMasterSwitchOn.value ? 1.0 : 0.5,
              child: AbsorbPointer(
                absorbing: !isMasterSwitchOn.value,
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
                      borderRadius: BorderRadius.circular(
                          ScreenUtilHelper.setHeight(20))),
                  child: ListTile(
                    title: Text("沉浸式通知",
                        style: TextStyle(
                            color: const Color(0xFF323031),
                            fontSize: ScreenUtilHelper.setSp(20),
                            fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding:
                          EdgeInsets.only(top: ScreenUtilHelper.setWidth(2)),
                      child: Text(
                        "", // 使用 RxBool 的值
                        style: TextStyle(fontSize: ScreenUtilHelper.setSp(14)),
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isNotificationReminder.value
                                  ? const Color.fromRGBO(71, 234, 139, 0.3)
                                  : const Color.fromRGBO(255, 70, 80, 0.3),
                              offset: const Offset(5, 3),
                              blurRadius: 5,
                              spreadRadius: 0,
                            ),
                          ]),
                      child: SwitcherXlive(
                        value: isNotificationReminder.value, // 使用 RxBool 的值
                        onChanged: _setNotificationReminder,
                        activeColor: const Color(0xFF47EA8B),
                        unActiveColor: const Color(0xFFFF4650),
                        thumbColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )),

        // 天气闹钟开关
        Obx(() => Opacity(
              opacity: isMasterSwitchOn.value ? 1.0 : 0.5,
              child: AbsorbPointer(
                absorbing: !isMasterSwitchOn.value,
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
                      borderRadius: BorderRadius.circular(
                          ScreenUtilHelper.setHeight(20))),
                  child: ListTile(
                    title: Text("睡眠闹钟",
                        style: TextStyle(
                            color: const Color(0xFF323031),
                            fontSize: ScreenUtilHelper.setSp(20),
                            fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding:
                          EdgeInsets.only(top: ScreenUtilHelper.setWidth(2)),
                      child: Text(
                        "", // 使用 RxBool 的值
                        style: TextStyle(fontSize: ScreenUtilHelper.setSp(14)),
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isWeatherAlarmEnabled.value




                                  ? const Color.fromRGBO(71, 234, 139, 0.3)
                                  : const Color.fromRGBO(255, 70, 80, 0.3),
                              offset: const Offset(5, 3),
                              blurRadius: 5,
                              spreadRadius: 0,
                            ),
                          ]),
                      child: SwitcherXlive(
                        value: isWeatherAlarmEnabled.value, // 使用 RxBool 的值
                        onChanged: _setWeatherAlarmEnabled,
                        activeColor: const Color(0xFF47EA8B),
                        unActiveColor: const Color(0xFFFF4650),
                        thumbColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )),

        ///
        /// Row(
        //               Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     Text(
        //                       '一言',
        //                       style: TextStyle(
        //                         color: Colors.white,
        //                         fontSize: ScreenUtilHelper.setSp(35),
        //                       ),
        //                     ),
        //                     SwitcherXlive(
        //                       value: isAWordDay.value,
        //                       onChanged: _setAWordDay,
        //                     ),
        //                   ],
        //                 )

        // 一言开关
        Obx(() => Opacity(
              opacity: isMasterSwitchOn.value ? 1.0 : 0.5,
              child: AbsorbPointer(
                absorbing: !isMasterSwitchOn.value,
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
                      borderRadius: BorderRadius.circular(
                          ScreenUtilHelper.setHeight(20))),
                  child: ListTile(
                    title: Text("每日一言",
                        style: TextStyle(
                            color: const Color(0xFF323031),
                            fontSize: ScreenUtilHelper.setSp(20),
                            fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding:
                          EdgeInsets.only(top: ScreenUtilHelper.setWidth(2)),
                      child: Text(
                        "", // 使用 RxBool 的值
                        style: TextStyle(fontSize: ScreenUtilHelper.setSp(14)),
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isAWordDay.value
                                  ? const Color.fromRGBO(71, 234, 139, 0.3)
                                  : const Color.fromRGBO(255, 70, 80, 0.3),
                              offset: const Offset(5, 3),
                              blurRadius: 5,
                              spreadRadius: 0,
                            ),
                          ]),
                      child: SwitcherXlive(
                        value: isAWordDay.value, // 使用 RxBool 的值
                        onChanged: _setAWordDay,
                        activeColor: const Color(0xFF47EA8B),
                        unActiveColor: const Color(0xFFFF4650),
                        thumbColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )),

        // 如果开启了天气闹钟，显示时间选择器
        Obx(() => Visibility(
              visible: isWeatherAlarmEnabled.value && isMasterSwitchOn.value,
              child: const Column(
                children: [
                  // // 起床时间选择
                  // TimePickerSpinner(
                  //   is24HourMode: true,
                  //   normalTextStyle: TextStyle(
                  //     fontSize: ScreenUtilHelper.setSp(35),
                  //     color: Colors.grey,
                  //   ),
                  //   highlightedTextStyle: TextStyle(
                  //     fontSize: ScreenUtilHelper.setSp(35),
                  //     color: Colors.white,
                  //   ),
                  //   spacing: 50,
                  //   itemHeight: 80,
                  //   onTimeChange: (time) {
                  //     outBedTimeTimestampInSeconds.value =
                  //         Utils().calculateTimestamp(Time(time.hour, time.minute));
                  //     SpUtils.setInt("_outBedTime", outBedTimeTimestampInSeconds.value);
                  //   },
                  // ),

                  // 就寝时间选择
                  // TimePickerSpinner(
                  //   is24HourMode: true,
                  //   normalTextStyle: TextStyle(
                  //     fontSize: ScreenUtilHelper.setSp(35),
                  //     color: Colors.grey,
                  //   ),
                  //   highlightedTextStyle: TextStyle(
                  //     fontSize: ScreenUtilHelper.setSp(35),
                  //     color: Colors.white,
                  //   ),
                  //   spacing: 50,
                  //   itemHeight: 80,
                  //   onTimeChange: (time) {
                  //     inBedTimeTimestampInSeconds.value =
                  //         Utils().calculateTimestamp(Time(time.hour, time.minute));
                  //     SpUtils.setInt("inBedTime", inBedTimeTimestampInSeconds.value);
                  //   },
                  // ),
                ],
              ),
            )),

        // 添加跳转到 ContainerActivity 的按钮
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            title: const Text(
              "打开轮播页面",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              const platform = MethodChannel('com.example.flutter_screen_clock/master_switch');
              try {
                await platform.invokeMethod('openContainer', {
                  'master_switch_state': isMasterSwitchOn.value
                });
              } catch (e) {
                print('Error opening ContainerActivity: $e');
              }
            },
          ),
        ),
      ],
    );
  }

  // 辅助方法：检查并启动通知服务
  Future<void> _checkAndStartNotificationService() async {
    try {
      final hasPermission =
          await NotificationService.instance.checkNotificationPermission();
      if (hasPermission) {
        NotificationService.instance.startListening();
        isNotificationReminder.value = true;
        SpUtils.setBool("isNotificationReminder", true);
      } else {
        isNotificationReminder.value = false;
        SpUtils.setBool("isNotificationReminder", false);
        NativeToast.showToast("权限获取异常，请重新开启权限");
      }
    } catch (e) {
      isNotificationReminder.value = false;
      SpUtils.setBool("isNotificationReminder", false);
      NativeToast.showToast("权限获取异常，请重新开启权限");
      debugPrint("权限检查异常: $e");
    }
  }

  Future<bool> getMasterSwitchState() async {
    try {
      return isMasterSwitchOn.value;
    } catch (e) {
      print("Error getting master switch state: $e");
      return false;
    }
  }
}
