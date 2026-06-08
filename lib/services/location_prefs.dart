import 'package:shared_preferences/shared_preferences.dart';

/// Tanlangan viloyatni localga saqlash uchun yordamchi.
class LocationPrefs {
  static const _cityKey = 'selected_city';
  static const _regionKey = 'selected_region';
  static const defaultCity = 'Toshkent';

  /// [city] - ekranda ko'rinadigan nom, [region] - islomapi'ga yuboriladigan nom.
  static Future<void> save(String city, String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, city);
    await prefs.setString(_regionKey, region);
  }

  static Future<String> getCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey) ?? defaultCity;
  }

  static Future<String> getRegion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_regionKey) ?? defaultCity;
  }
}
