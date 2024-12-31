
import 'dart:convert';

import '../http/DioClient.dart';

HttpService httpService = HttpService();

class Weather {
  static fetch () async {
    final  response = await httpService.get('/weather/query?appkey=2c99829512138cc0&city=武昌区');

    if (response.statusCode == 200) {
      var jsonData = json.encode(response.data);

      Map<String, dynamic> jsonDatas = json.decode(jsonData) as Map<String, dynamic>;

      WeatherModel model = WeatherModel.fromJson(jsonDatas);

      print(model);
      return model;
    } else {
      throw Exception('Failed to load home_page.json');
    }

  }
}

/// model
///
///
class Result {
  String? city;
  int? cityid;
  // int? citycode;
  String? date;
  String? week;
  String? weather;
  String? temp;
  String? temphigh;
  String? templow;
  String? img;
  String? humidity;
  String? pressure;
  String? windspeed;
  String? winddirect;
  String? windpower;
  String? updatetime;

  Result({this.city, this.cityid,this.date, this.week, this.weather, this.temp, this.temphigh, this.templow, this.img, this.humidity, this.pressure, this.windspeed, this.winddirect, this.windpower, this.updatetime});

  Result.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    cityid = json['cityid'];
    // citycode = json['citycode'];
    date = json['date'];
    week = json['week'];
    weather = json['weather'];
    temp = json['temp'];
    temphigh = json['temphigh'];
    templow = json['templow'];
    img = json['img'];
    humidity = json['humidity'];
    pressure = json['pressure'];
    windspeed = json['windspeed'];
    winddirect = json['winddirect'];
    windpower = json['windpower'];
    updatetime = json['updatetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['cityid'] = cityid;
    data['date'] = date;
    data['week'] = week;
    data['weather'] = weather;
    data['temp'] = temp;
    data['temphigh'] = temphigh;
    data['templow'] = templow;
    data['img'] = img;
    data['humidity'] = humidity;
    data['pressure'] = pressure;
    data['windspeed'] = windspeed;
    data['winddirect'] = winddirect;
    data['windpower'] = windpower;
    data['updatetime'] = updatetime;
    return data;
  }
}

class WeatherModel {
  int? status;
  String? msg;
  Result? result;

  WeatherModel({this.status, this.msg, this.result});

  WeatherModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    result = json['result'] != null ? Result?.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['msg'] = msg;
    data['result'] = result!.toJson();
    return data;
  }
}