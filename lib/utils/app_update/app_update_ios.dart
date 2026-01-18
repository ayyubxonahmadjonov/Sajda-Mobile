import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppUpdateService {
  // App Store'dagi ilovangiz ID'si
  final String appStoreId = '6754518453'; // O'zingiznikini yozing
  
  Future<void> checkForUpdate() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      
      // App Store'dan oxirgi versiyani tekshirish
      final response = await http.get(
        Uri.parse('https://itunes.apple.com/lookup?id=$appStoreId')
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['resultCount'] > 0) {
          String storeVersion = data['results'][0]['version'];
          
          if (_isUpdateAvailable(currentVersion, storeVersion)) {
            _showUpdateDialog();
          }
        }
      }
    } catch (e) {
      print('Update tekshirishda xato: $e');
    }
  }
  
  bool _isUpdateAvailable(String current, String store) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> storeParts = store.split('.').map(int.parse).toList();
    
    for (int i = 0; i < currentParts.length; i++) {
      if (storeParts[i] > currentParts[i]) return true;
      if (storeParts[i] < currentParts[i]) return false;
    }
    return false;
  }
  
  void _showUpdateDialog() {
    // Dialog ko'rsatish kodi (keyingi qismda)
  }
  
  Future<void> openAppStore() async {
    final url = 'https://apps.apple.com/app/id$appStoreId';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}