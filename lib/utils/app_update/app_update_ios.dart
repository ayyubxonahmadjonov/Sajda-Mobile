import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class IOSUpdateService {
  static const String appStoreId = '6754518453';

  /// 🔑 TRUE qaytsa → update bor, navigatsiya to‘xtaydi
  /// 🔑 FALSE qaytsa → update yo‘q, navigatsiya davom etadi
  Future<bool> check(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse('https://itunes.apple.com/lookup?id=$appStoreId'),
      );

      if (response.statusCode != 200) return false;

      final data = json.decode(response.body);
      if (data['resultCount'] == 0) return false;

      final storeVersion = data['results'][0]['version'];
      final releaseNotes = data['results'][0]['releaseNotes'] ?? '';

      if (_isNewer(storeVersion, currentVersion)) {
        if (!context.mounted) return false;

        // 🔒 Dialog chiqdi → navigatsiya STOP
        await _showUpdateDialog(context, storeVersion, releaseNotes);
        return true;
      }
    } catch (e) {
      debugPrint('iOS update error: $e');
    }
    return false;
  }

  bool _isNewer(String store, String local) {
    final storeParts = store.split('.').map(int.parse).toList();
    final localParts = local.split('.').map(int.parse).toList();

    for (int i = 0; i < storeParts.length; i++) {
      final s = storeParts[i];
      final l = i < localParts.length ? localParts[i] : 0;
      if (s > l) return true;
      if (s < l) return false;
    }
    return false;
  }

  /// ⚠️ MUHIM: Future<void> — await qilinadi
  Future<void> _showUpdateDialog(
    BuildContext context,
    String version,
    String notes,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Yangi versiya mavjud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versiya: $version'),
            const SizedBox(height: 12),
            if (notes.isNotEmpty) Text(notes),
          ],
        ),
        actions: [
          // ✅ Keyinroq → dialog yopiladi → Splash navigatsiya qiladi
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Keyinroq'),
          ),

          // 🔒 Yangilash → App Store ochiladi → navigatsiya bo‘lmaydi
          ElevatedButton(
            onPressed: () {
              _openAppStore();
            },
            child: const Text('Yangilash'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppStore() async {
    final url = Uri.parse(
      'https://apps.apple.com/app/id$appStoreId',
    );

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      debugPrint('App Store ochilmadi');
    }
  }
}
