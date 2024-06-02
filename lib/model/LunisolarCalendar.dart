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
      this._status = status;
    }
    if (msg != null) {
      this._msg = msg;
    }
    if (result != null) {
      this._result = result;
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
    json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this._status;
    data['msg'] = this._msg;
    if (this._result != null) {
      data['result'] = this._result!.toJson();
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
      this._year = year;
    }
    if (month != null) {
      this._month = month;
    }
    if (day != null) {
      this._day = day;
    }
    if (yangli != null) {
      this._yangli = yangli;
    }
    if (nongli != null) {
      this._nongli = nongli;
    }
    if (star != null) {
      this._star = star;
    }
    if (taishen != null) {
      this._taishen = taishen;
    }
    if (wuxing != null) {
      this._wuxing = wuxing;
    }
    if (chong != null) {
      this._chong = chong;
    }
    if (sha != null) {
      this._sha = sha;
    }
    if (shengxiao != null) {
      this._shengxiao = shengxiao;
    }
    if (jiri != null) {
      this._jiri = jiri;
    }
    if (zhiri != null) {
      this._zhiri = zhiri;
    }
    if (xiongshen != null) {
      this._xiongshen = xiongshen;
    }
    if (jishenyiqu != null) {
      this._jishenyiqu = jishenyiqu;
    }
    if (caishen != null) {
      this._caishen = caishen;
    }
    if (xishen != null) {
      this._xishen = xishen;
    }
    if (fushen != null) {
      this._fushen = fushen;
    }
    if (suici != null) {
      this._suici = suici;
    }
    if (yi != null) {
      this._yi = yi;
    }
    if (ji != null) {
      this._ji = ji;
    }
    if (eweek != null) {
      this._eweek = eweek;
    }
    if (emonth != null) {
      this._emonth = emonth;
    }
    if (week != null) {
      this._week = week;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['year'] = this._year;
    data['month'] = this._month;
    data['day'] = this._day;
    data['yangli'] = this._yangli;
    data['nongli'] = this._nongli;
    data['star'] = this._star;
    data['taishen'] = this._taishen;
    data['wuxing'] = this._wuxing;
    data['chong'] = this._chong;
    data['sha'] = this._sha;
    data['shengxiao'] = this._shengxiao;
    data['jiri'] = this._jiri;
    data['zhiri'] = this._zhiri;
    data['xiongshen'] = this._xiongshen;
    data['jishenyiqu'] = this._jishenyiqu;
    data['caishen'] = this._caishen;
    data['xishen'] = this._xishen;
    data['fushen'] = this._fushen;
    data['suici'] = this._suici;
    data['yi'] = this._yi;
    data['ji'] = this._ji;
    data['eweek'] = this._eweek;
    data['emonth'] = this._emonth;
    data['week'] = this._week;
    return data;
  }
}

final person = Rx<LunisolarCalendarModel>(LunisolarCalendarModel());