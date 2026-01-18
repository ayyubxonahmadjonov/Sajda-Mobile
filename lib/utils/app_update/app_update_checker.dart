import 'package:in_app_update/in_app_update.dart';

class UpdateChecker {
  Future<void> checkForUpdate() async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        }

        else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          
          InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (e) {
      print('Update xatosi: $e');
    }
  }
}