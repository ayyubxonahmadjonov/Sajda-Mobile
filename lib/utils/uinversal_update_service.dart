import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:sajda_app/utils/app_update/app_update_ios.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ilova yangilanishini boshqaradi: HomeScreen'да custom dialog ko'rsatadi,
/// "Keyinroq" bosilса 3 kun kutadi, faqat tugmalar orqali yopiladi.
class UpdateManager {
  static const _snoozeKey = 'update_snooze_until';
  static const _snoozeDuration = Duration(days: 3);
  static const _androidPackage = 'uz.ayyubxon.sajda_app';

  // Sessiya davomida faqat bir marta tekshiramiz (tab almashsa takrorlanmasin).
  static bool _checkedThisSession = false;

  /// HomeScreen ochilganда chaqiriladi.
  Future<void> checkAndPrompt(BuildContext context) async {
    if (_checkedThisSession) return;
    _checkedThisSession = true;
    try {
      // 3 kunlik snooze ichидамизми?
      final prefs = await SharedPreferences.getInstance();
      final snoozeUntil = prefs.getInt(_snoozeKey) ?? 0;
      if (DateTime.now().millisecondsSinceEpoch < snoozeUntil) return;

      if (Platform.isIOS) {
        final update = await IOSUpdateService().fetchStoreUpdate();
        if (update == null || !context.mounted) return;
        await _showDialog(
          context,
          version: update.version,
          notes: update.notes,
          onUpdate: () => IOSUpdateService().openStore(),
        );
      } else if (Platform.isAndroid) {
        final info = await InAppUpdate.checkForUpdate()
            .timeout(const Duration(seconds: 6));
        if (info.updateAvailability != UpdateAvailability.updateAvailable) {
          return;
        }
        if (!context.mounted) return;
        await _showDialog(
          context,
          version: null,
          notes: '',
          onUpdate: _startAndroidUpdate,
        );
      }
    } catch (e) {
      debugPrint('Update tekshiruvi xatosi: $e');
    }
  }

  Future<void> _startAndroidUpdate() async {
    try {
      // Avval Play Core orqali ilova ichида yangilashga urinamiz.
      await InAppUpdate.performImmediateUpdate();
    } catch (_) {
      // Bo'lmasa Play Store sahifasini ochamiz.
      final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=$_androidPackage',
      );
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _snooze() async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(_snoozeDuration).millisecondsSinceEpoch;
    await prefs.setInt(_snoozeKey, until);
  }

  Future<void> _showDialog(
    BuildContext context, {
    required String? version,
    required String notes,
    required Future<void> Function() onUpdate,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? Colors.white : Colors.black87;

    return showDialog(
      context: context,
      barrierDismissible: false, // tashqariga bosсa yopilmaydi
      builder: (dialogCtx) => PopScope(
        canPop: false, // orqaga tugmasi bilan yopilmaydi
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF121931) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.system_update_rounded, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Yangi versiya mavjud',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: onBg,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                version != null
                    ? 'Ilovaning $version versiyasi chiqdi. Eng so‘nggi '
                        'imkoniyatlar va tuzatishlar uchun yangilashni tavsiya '
                        'qilamiz.'
                    : 'Ilovaning yangi versiyasi chiqdi. Eng so‘nggi '
                        'imkoniyatlar va tuzatishlar uchun yangilashni tavsiya '
                        'qilamiz.',
                style: GoogleFonts.poppins(fontSize: 13.5, color: text),
              ),
              if (notes.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Yangiliklar:',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notes.trim(),
                  style: GoogleFonts.poppins(fontSize: 12.5, color: text),
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          actions: [
            TextButton(
              onPressed: () async {
                await _snooze(); // 3 kun kutadi
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              },
              child: Text(
                'Keyinroq',
                style: GoogleFonts.poppins(
                  color: text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await _snooze();
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                await onUpdate();
              },
              child: Text(
                'Yangilash',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
