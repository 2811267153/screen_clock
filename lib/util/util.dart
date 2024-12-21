
class Time {
  final int h;
  final int m;
  Time(this.h, this.m);
}

typedef Callback<T> = void Function(T);

class Utils {

    int calculateTimestamp(Time time) {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final timeDateTime = DateTime(now.year, now.month, now.day, time.h, time.m);
    final timeDifference = timeDateTime.difference(midnight);
    return timeDifference.inSeconds;
  }

   void _calculateAndPrintTimestamps(Time inBedTime, Time outBedTime) {
    final currentTimestampInSeconds = calculateTimestamp(Time(DateTime.now().hour, DateTime.now().minute));
    final inBedTimeTimestampInSeconds = calculateTimestamp(inBedTime);
    final outBedTimeTimestampInSeconds = calculateTimestamp(outBedTime);

    print("Current timestamp in seconds: $currentTimestampInSeconds");
    print("InBedTime: ${inBedTime.h}:${inBedTime.m}");
    print("InBedTime timestamp in seconds: $inBedTimeTimestampInSeconds");
    print("OutBedTime: ${outBedTime.h}:${outBedTime.m}");
    print("OutBedTime timestamp in seconds: $outBedTimeTimestampInSeconds");
  }
}