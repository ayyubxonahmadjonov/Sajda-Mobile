class NamozTime {
  final String region;
  final String date;
  final Times times;

  NamozTime({
    required this.region,
    required this.date,
    required this.times,
  });

  // islomapi.uz response parser
  // {"region":"Toshkent","date":"2025-06-08T...","times":{...}}
  factory NamozTime.fromIslomApi(
    Map<String, dynamic> json, {
    required String regionName,
  }) {
    final times = json['times'] as Map<String, dynamic>;
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return NamozTime(
      region: regionName,
      date: date,
      times: Times.fromIslomApi(times),
    );
  }

  Map<String, dynamic> toJson() => {
    'region': region,
    'date': date,
    'times': times.toJson(),
  };
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

  // islomapi: tong_saharlik→Bomdod, quyosh→Quyosh, peshin→Peshin,
  //           asr→Asr, shom_iftor→Shom, hufton→Xufton
  factory Times.fromIslomApi(Map<String, dynamic> t) {
    return Times(
      bomdod: (t['tong_saharlik'] ?? '').toString().trim(),
      quyosh: (t['quyosh'] ?? '').toString().trim(),
      peshin: (t['peshin'] ?? '').toString().trim(),
      asr: (t['asr'] ?? '').toString().trim(),
      shom: (t['shom_iftor'] ?? '').toString().trim(),
      xufton: (t['hufton'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    'bomdod': bomdod,
    'quyosh': quyosh,
    'peshin': peshin,
    'asr': asr,
    'shom': shom,
    'xufton': xufton,
  };
}
