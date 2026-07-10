import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sajda_app/app/constants/globals.dart';

class CommentsPage extends StatelessWidget {
  const CommentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.black.withOpacity(0.8)
                        : text,
              ),
            ),
            Text(
              'Murojat uchun',
              style: GoogleFonts.abrilFatface(
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            Text(
              'Sajda ilovasidan foydalanganingiz uchun tashakkur! Ilovada kamchilik sezsangiz yoki savol va takliflaringiz bo`lsa, quyidagi email yoki telegram manzilga izoh qoldirishingiz mumkin. Fikringiz biz uchun juda muhim.',
              style: GoogleFonts.poppins(
                color:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Email: kamronqodirov441@gmail.com',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  'T.me:@ayyubxon_akhmadjonov',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    color:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '';
                    return Text(
                      version.isEmpty ? 'Versiya: —' : 'Versiya: $version',
                      textAlign: TextAlign.end,
                      style: GoogleFonts.poppins(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
