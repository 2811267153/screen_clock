import 'dart:convert';

import 'package:dio/src/response.dart' as dio;
import 'package:get/get.dart';

import '../http/DioClient.dart';

HttpService httpService = HttpService();

class LunisolarCalendar {
  static fetch(int Y, int M, int D) async {
    // 发起 GET 请求
    dio.Response response = await httpService.get('/huangli/date?appkey=2c99829512138cc0&year=$Y&month=$M&day=$D');

    if (response.statusCode == 200) {
      var jsonData = json.encode(response.data);

      Map<String, dynamic> jsonDatas = json.decode(jsonData) as Map<String, dynamic>;

      LunisolarCalendarModel model = LunisolarCalendarModel.fromJson(jsonDatas);

      print(model);
      return model;
    } else {
      throw Exception('Failed to load home_page.json');
    }

  }

}
///
class LunisolarCalendarModel {
  int? _status;
  String? _msg;
  Result? _result;

  LunisolarCalendarModel({int? status, String? msg, Result? result}) {
    if (status != null) {
      _status = status;
    }
    if (msg != null) {
      _msg = msg;
    }
    if (result != null) {
      _result = result;
    }
  }

  int? get status => _status;
  set status(int? status) => _status = status;
  String? get msg => _msg;
  set msg(String? msg) => _msg = msg;
  Result? get result => _result;
  set result(Result? result) => _result = result;

  LunisolarCalendarModel.fromJson(Map<String, dynamic> json) {
    _status = json['status'];
    _msg = json['msg'];
    _result =
    json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = _status;
    data['msg'] = _msg;
    if (_result != null) {
      data['result'] = _result!.toJson();
    }
    return data;
  }
}

class Result {
  String? _year;
  String? _month;
  String? _day;
  String? _yangli;
  String? _nongli;
  String? _star;
  String? _taishen;
  String? _wuxing;
  String? _chong;
  String? _sha;
  String? _shengxiao;
  String? _jiri;
  String? _zhiri;
  String? _xiongshen;
  String? _jishenyiqu;
  String? _caishen;
  String? _xishen;
  String? _fushen;
  List<String>? _suici;
  List<String>? _yi;
  List<String>? _ji;
  String? _eweek;
  String? _emonth;
  String? _week;

  Result(
      {String? year,
        String? month,
        String? day,
        String? yangli,
        String? nongli,
        String? star,
        String? taishen,
        String? wuxing,
        String? chong,
        String? sha,
        String? shengxiao,
        String? jiri,
        String? zhiri,
        String? xiongshen,
        String? jishenyiqu,
        String? caishen,
        String? xishen,
        String? fushen,
        List<String>? suici,
        List<String>? yi,
        List<String>? ji,
        String? eweek,
        String? emonth,
        String? week}) {
    if (year != null) {
      _year = year;
    }
    if (month != null) {
      _month = month;
    }
    if (day != null) {
      _day = day;
    }
    if (yangli != null) {
      _yangli = yangli;
    }
    if (nongli != null) {
      _nongli = nongli;
    }
    if (star != null) {
      _star = star;
    }
    if (taishen != null) {
      _taishen = taishen;
    }
    if (wuxing != null) {
      _wuxing = wuxing;
    }
    if (chong != null) {
      _chong = chong;
    }
    if (sha != null) {
      _sha = sha;
    }
    if (shengxiao != null) {
      _shengxiao = shengxiao;
    }
    if (jiri != null) {
      _jiri = jiri;
    }
    if (zhiri != null) {
      _zhiri = zhiri;
    }
    if (xiongshen != null) {
      _xiongshen = xiongshen;
    }
    if (jishenyiqu != null) {
      _jishenyiqu = jishenyiqu;
    }
    if (caishen != null) {
      _caishen = caishen;
    }
    if (xishen != null) {
      _xishen = xishen;
    }
    if (fushen != null) {
      _fushen = fushen;
    }
    if (suici != null) {
      _suici = suici;
    }
    if (yi != null) {
      _yi = yi;
    }
    if (ji != null) {
      _ji = ji;
    }
    if (eweek != null) {
      _eweek = eweek;
    }
    if (emonth != null) {
      _emonth = emonth;
    }
    if (week != null) {
      _week = week;
    }
  }

  String? get year => _year;
  set year(String? year) => _year = year;
  String? get month => _month;
  set month(String? month) => _month = month;
  String? get day => _day;
  set day(String? day) => _day = day;
  String? get yangli => _yangli;
  set yangli(String? yangli) => _yangli = yangli;
  String? get nongli => _nongli;
  set nongli(String? nongli) => _nongli = nongli;
  String? get star => _star;
  set star(String? star) => _star = star;
  String? get taishen => _taishen;
  set taishen(String? taishen) => _taishen = taishen;
  String? get wuxing => _wuxing;
  set wuxing(String? wuxing) => _wuxing = wuxing;
  String? get chong => _chong;
  set chong(String? chong) => _chong = chong;
  String? get sha => _sha;
  set sha(String? sha) => _sha = sha;
  String? get shengxiao => _shengxiao;
  set shengxiao(String? shengxiao) => _shengxiao = shengxiao;
  String? get jiri => _jiri;
  set jiri(String? jiri) => _jiri = jiri;
  String? get zhiri => _zhiri;
  set zhiri(String? zhiri) => _zhiri = zhiri;
  String? get xiongshen => _xiongshen;
  set xiongshen(String? xiongshen) => _xiongshen = xiongshen;
  String? get jishenyiqu => _jishenyiqu;
  set jishenyiqu(String? jishenyiqu) => _jishenyiqu = jishenyiqu;
  String? get caishen => _caishen;
  set caishen(String? caishen) => _caishen = caishen;
  String? get xishen => _xishen;
  set xishen(String? xishen) => _xishen = xishen;
  String? get fushen => _fushen;
  set fushen(String? fushen) => _fushen = fushen;
  List<String>? get suici => _suici;
  set suici(List<String>? suici) => _suici = suici;
  List<String>? get yi => _yi;
  set yi(List<String>? yi) => _yi = yi;
  List<String>? get ji => _ji;
  set ji(List<String>? ji) => _ji = ji;
  String? get eweek => _eweek;
  set eweek(String? eweek) => _eweek = eweek;
  String? get emonth => _emonth;
  set emonth(String? emonth) => _emonth = emonth;
  String? get week => _week;
  set week(String? week) => _week = week;

  Result.fromJson(Map<String, dynamic> json) {
    _year = json['year'];
    _month = json['month'];
    _day = json['day'];
    _yangli = json['yangli'];
    _nongli = json['nongli'];
    _star = json['star'];
    _taishen = json['taishen'];
    _wuxing = json['wuxing'];
    _chong = json['chong'];
    _sha = json['sha'];
    _shengxiao = json['shengxiao'];
    _jiri = json['jiri'];
    _zhiri = json['zhiri'];
    _xiongshen = json['xiongshen'];
    _jishenyiqu = json['jishenyiqu'];
    _caishen = json['caishen'];
    _xishen = json['xishen'];
    _fushen = json['fushen'];
    _suici = json['suici'].cast<String>();
    _yi = json['yi'].cast<String>();
    _ji = json['ji'].cast<String>();
    _eweek = json['eweek'];
    _emonth = json['emonth'];
    _week = json['week'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['year'] = _year;
    data['month'] = _month;
    data['day'] = _day;
    data['yangli'] = _yangli;
    data['nongli'] = _nongli;
    data['star'] = _star;
    data['taishen'] = _taishen;
    data['wuxing'] = _wuxing;
    data['chong'] = _chong;
    data['sha'] = _sha;
    data['shengxiao'] = _shengxiao;
    data['jiri'] = _jiri;
    data['zhiri'] = _zhiri;
    data['xiongshen'] = _xiongshen;
    data['jishenyiqu'] = _jishenyiqu;
    data['caishen'] = _caishen;
    data['xishen'] = _xishen;
    data['fushen'] = _fushen;
    data['suici'] = _suici;
    data['yi'] = _yi;
    data['ji'] = _ji;
    data['eweek'] = _eweek;
    data['emonth'] = _emonth;
    data['week'] = _week;
    return data;
  }
}

final person = Rx<LunisolarCalendarModel>(LunisolarCalendarModel());