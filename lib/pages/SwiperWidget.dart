
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_clock/pages/some_page.dart';
import 'package:get/get.dart';

import '../controller/HomePageController.dart';
import 'ClockWidget.dart';
import 'WeatherWidget.dart';

///轮播组件
 class SwiperContainer extends StatefulWidget{
   const SwiperContainer({super.key});
  @override
  State<StatefulWidget> createState() => _SwiperContainer();
}

class _SwiperContainer extends State<SwiperContainer> with WidgetsBindingObserver{


  final MyHomePageController homePageController = Get.put(MyHomePageController());


  int isRotate = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final orientation = MediaQuery.of(context).orientation;
    setState(() {
       isRotate = orientation == Orientation.portrait ? 1 : 0;
    });
  }

  @override
  void deactivate() {
    super.deactivate();
    WidgetsBinding.instance.removeObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
  }

  @override
  Widget build(BuildContext context) {

    late List<Widget> itemWidget = <Widget>[
      ClockWidget(),
      WeatherWidget(weatherModel: homePageController.weatherModel.value, lunisolarCalendarModel: homePageController.lunisolarCalendarModel.value, color: Color(0xFFFF4650),)]; // 初始化itemWidget

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: MediaQuery.of(context).padding.right),
        color: Colors.black,
        child: Hero(
          tag: "swiper_container",
          child: Swiper(
            autoplay: false,
            duration: 500,
            autoplayDelay: 120000,
            itemBuilder: (BuildContext context, int index) {
              return itemWidget[index];
            },
            transformer: ScaleAndFadeTransformer(scale: 0.7),
            itemCount: itemWidget.length,
          ),
        ),
      ),
    );
  }


}
