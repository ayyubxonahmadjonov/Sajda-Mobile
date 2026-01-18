class NamozTime {
  String? region; // user tanlagan shahar
  String? date;   // gregorian readable date
  String? weekday; // haftaning kuni (inglizcha)
  Times? times;

  NamozTime({this.region, this.date, this.weekday, this.times});

  factory NamozTime.fromJson(Map<String, dynamic> json, {String? regionName}) {
    final data = json['data'];
    final timings = data['timings'];

    // gregorian date va weekday
    final dateInfo = data['date']['gregorian'];
    final readableDate = data['date']['readable'];
    final weekday = dateInfo['weekday']['en'];

    return NamozTime(
      region: regionName,
      date: readableDate,
      weekday: weekday,
      times: Times.fromJson(timings),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'date': date,
      'weekday': weekday,
      'times': times?.toJson(),
    };
  }
}

class Times {
  String? tongSaharlik; // Fajr
  String? quyosh;       // Sunrise
  String? peshin;       // Dhuhr
  String? asr;          // Asr
  String? shomIftor;    // Maghrib
  String? hufton;       // Isha

  Times({
    this.tongSaharlik,
    this.quyosh,
    this.peshin,
    this.asr,
    this.shomIftor,
    this.hufton,
  });

  factory Times.fromJson(Map<String, dynamic> json) {
    return Times(
      tongSaharlik: json['Fajr'],
      quyosh: json['Sunrise'],
      peshin: json['Dhuhr'],
      asr: json['Asr'],
      shomIftor: json['Maghrib'],
      hufton: json['Isha'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tong_saharlik': tongSaharlik,
      'quyosh': quyosh,
      'peshin': peshin,
      'asr': asr,
      'shom_iftor': shomIftor,
      'hufton': hufton,
    };
  }
}
