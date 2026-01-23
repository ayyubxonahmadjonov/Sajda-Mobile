import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:sajda_app/utils/app_update/app_update_ios.dart';


class UniversalUpdateService {
  Future<bool> checkForUpdate(BuildContext context) async {
    if (Platform.isAndroid) {
      return await AndroidUpdateService().check();
    } else if (Platform.isIOS) {
      return await IOSUpdateService().check(context);
    }
    return false;
  }
}

class AndroidUpdateService {
  Future<bool> check() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
          return true; // 🔒 update bor
        }
      }
    } catch (e) {
      debugPrint('Android update error: $e');
    }
    return false; // update yo‘q
  }
}
