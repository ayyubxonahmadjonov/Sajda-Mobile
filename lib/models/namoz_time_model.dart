class NamozTime {
  final String region;
  final String date;
  final Times times;

  NamozTime({
    required this.region,
    required this.date,
    required this.times,
  });

  // AlAdhan API response parser
  factory NamozTime.fromAlAdhan(
    Map<String, dynamic> json, {
    required String regionName,
  }) {
    final timings = json['data']['timings'] as Map<String, dynamic>;
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return NamozTime(
      region: regionName,
      date: date,
      times: Times.fromAlAdhan(timings),
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

  // AlAdhan: Fajr→Bomdod, Sunrise→Quyosh, Dhuhr→Peshin,
  //          Asr→Asr, Maghrib→Shom, Isha→Xufton
  factory Times.fromAlAdhan(Map<String, dynamic> t) {
    return Times(
      bomdod: _clean(t['Fajr'] ?? ''),
      quyosh: _clean(t['Sunrise'] ?? ''),
      peshin: _clean(t['Dhuhr'] ?? ''),
      asr:    _clean(t['Asr'] ?? ''),
      shom:   _clean(t['Maghrib'] ?? ''),
      xufton: _clean(t['Isha'] ?? ''),
    );
  }

  // "04:35 (UTC+5)" → "04:35"
  static String _clean(String raw) {
    final trimmed = raw.trim();
    final spaceIdx = trimmed.indexOf(' ');
    return spaceIdx == -1 ? trimmed : trimmed.substring(0, spaceIdx);
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
