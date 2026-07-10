import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// App Store'да ilovaning yangiroq versiyasi bor-yo'qligini tekshiradi.
class StoreUpdate {
  final String version;
  final String notes;
  const StoreUpdate(this.version, this.notes);
}

class IOSUpdateService {
  static const String appStoreId = '6754518453';

  /// Do'konда yangiroq versiya bo'lsa uning ma'lumotini qaytaradi, aks holda null.
  Future<StoreUpdate?> fetchStoreUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http
          .get(Uri.parse('https://itunes.apple.com/lookup?id=$appStoreId'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if ((data['resultCount'] ?? 0) == 0) return null;

      final result = data['results'][0];
      final storeVersion = (result['version'] ?? '').toString();
      final releaseNotes = (result['releaseNotes'] ?? '').toString();
      if (storeVersion.isEmpty) return null;

      if (_isNewer(storeVersion, currentVersion)) {
        return StoreUpdate(storeVersion, releaseNotes);
      }
    } catch (e) {
      debugPrint('iOS update error: $e');
    }
    return null;
  }

  /// [store] versiyasi [local]dan yangiroqmi? Raqamsiz segmentlarga chidamli.
  bool _isNewer(String store, String local) {
    final s = store.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    final l = local.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
    final len = s.length > l.length ? s.length : l.length;
    for (int i = 0; i < len; i++) {
      final sv = i < s.length ? s[i] : 0;
      final lv = i < l.length ? l[i] : 0;
      if (sv > lv) return true;
      if (sv < lv) return false;
    }
    return false;
  }

  Future<void> openStore() async {
    final url = Uri.parse('https://apps.apple.com/app/id$appStoreId');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('App Store ochilmadi');
    }
  }
}
