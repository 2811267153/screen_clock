import 'package:get/get.dart';

class PickedTime {
  final RxInt hour;
  final RxInt minute;

  PickedTime({int h = 0, int m = 0})
      : hour = RxInt(h),
        minute = RxInt(m);
}

final inBedTime = PickedTime(h: 0, m: 0);
final outBedTime = PickedTime(h: 8, m: 0);