import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:sajda_app/utils/app_update/app_update_ios.dart';


class UniversalUpdateService {
  Future<void> checkForUpdate(BuildContext context) async {
    if (Platform.isAndroid) {
      await _checkAndroidUpdate();
    } else if (Platform.isIOS) {
      await _checkIOSUpdate(context);
    }
  }

  Future<void> _checkAndroidUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        }
        else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (e) {
      print('Android update xato: $e');
    }
  }

  // iOS uchun
  Future<void> _checkIOSUpdate(BuildContext context) async {
    final appStoreService = AppUpdateService();
    await appStoreService.checkForUpdate();
  }
}