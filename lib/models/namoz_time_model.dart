class NamozTime {
  final String region; // Toshkent
  final String date;   // 2026-01-23
  final Times times;

  NamozTime({
    required this.region,
    required this.date,
    required this.times,
  });

  factory NamozTime.fromJson(
    Map<String, dynamic> json, {
    required String regionName,
    required String date,
  }) {
    // API structure:
    // { isSuccess, statusCode, response: { bomdod, quyosh, ... } }

    final response = json['response'];

    return NamozTime(
      region: regionName,
      date: date,
      times: Times.fromJson(response),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'date': date,
      'times': times.toJson(),
    };
  }
}
class Times {
  final String bomdod;
  final String quyosh;
  final String peshin;
  final String asr;
  final String shom;
  final String xufton;

  Times({
    required this.bomdod,
    required this.quyosh,
    required this.peshin,
    required this.asr,
    required this.shom,
    required this.xufton,
  });

  factory Times.fromJson(Map<String, dynamic> json) {
    return Times(
      bomdod: json['bomdod'],
      quyosh: json['quyosh'],
      peshin: json['peshin'],
      asr: json['asr'],
      shom: json['shom'],
      xufton: json['xufton'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bomdod': bomdod,
      'quyosh': quyosh,
      'peshin': peshin,
      'asr': asr,
      'shom': shom,
      'xufton': xufton,
    };
  }
}
