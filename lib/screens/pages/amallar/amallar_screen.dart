import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:sajda_app/screens/pages/tahorat_oliw.dart';
import 'guide_data.dart';
import 'guide_models.dart';
import 'guide_screen.dart';

/// "Amallar" tab'i — ibodat amallari bo'yicha qo'llanmalar ro'yxati.
/// Har bir qatorni bosganda bosqichma-bosqich ko'rsatkich ochiladi.
class AmallarScreen extends StatelessWidget {
  const AmallarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Amallar',
              style: GoogleFonts.poppins(
                color: onBg,
                fontWeight: FontWeight.w700,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ibodat amallari bo‘yicha qo‘llanmalar',
              style: GoogleFonts.poppins(color: text, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Tahorat (mavjud rasmli qo'llanma)
            _tile(
              context,
              icon: 'assets/svgs/g_wudu.svg',
              title: 'Tahorat olish',
              subtitle: 'Tahorat olish tartibi — rasmlar bilan',
              onTap: () => _open(context, const Ablution()),
            ),

            // Ma'lumotlar bilan boshqariladigan qo'llanmalar (namoz, g'usl)
            for (final Guide g in allGuides)
              _tile(
                context,
                icon: g.icon,
                title: g.title,
                subtitle: g.subtitle,
                onTap: () => _open(context, GuideScreen(guide: g)),
              ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _tile(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? gray : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(11),
                  child: SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: onBg,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: text,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
