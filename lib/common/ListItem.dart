import 'package:get/get_rx/src/rx_types/rx_types.dart';
typedef OnTapCallback = void Function({required String title, required String subTitle,});


class DataItem {
  String title;
  String subTitle;
  RxBool buttonValue;
  Function({required String title, required String subTitle}) onTap;

  DataItem({
    required this.title,
    required this.subTitle,
    required bool buttonValue,  // 接收普通 bool 值
    required this.onTap,
  }) : this.buttonValue = buttonValue.obs;  // 将 bool 转换为 RxBool
}


// List<DataItem> dataItems = [
//   DataItem(title: "睡眠", subTitle: "开启后改时间段内，屏幕亮度将会有所降低，在结束时恢复，并自动开启天气闹钟。", onTap: (){}),
//   DataItem(title: "沉浸式通知", subTitle: "开启后，将在时钟界面全屏显示通知。", onTap: (){})
// ];
