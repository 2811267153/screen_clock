import 'package:get/get.dart';
import '../model/LunisolarCalendar.dart';
import '../model/Weather.dart';

class MyHomePageController extends GetxController {
  var lunisolarCalendarModel = LunisolarCalendarModel().obs;
  var weatherModel = WeatherModel().obs;

  void updateData<T>(T data) {
    if (data is WeatherModel) {
      weatherModel.value = data;
    } else if (data is LunisolarCalendarModel) {
      lunisolarCalendarModel.value = data;
    }
  }
}
