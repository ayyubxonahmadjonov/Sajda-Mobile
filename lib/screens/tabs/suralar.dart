import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:sajda_app/bloc_state_manegment/disableSura/disable_sura_bloc.dart';
import 'package:sajda_app/models/surah.dart';
import 'package:sajda_app/screens/detail_screen.dart';

class SurahTab extends StatefulWidget {
  const SurahTab({super.key});

  @override
  State<SurahTab> createState() => _SurahTabState();
}

class _SurahTabState extends State<SurahTab> {
  String _searchQuery = '';
  late final Future<List<Surah>> _surahFuture;

  @override
  void initState() {
    super.initState();
    _surahFuture = _loadSurahs();
  }

  Future<List<Surah>> _loadSurahs() async {
    final data = await rootBundle.loadString('assets/datas/list-surah.json');
    return surahFromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Sura qidirish...',
              hintStyle: GoogleFonts.poppins(color: text, fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: text, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded, color: text, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF121931) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        // Surah list
        Expanded(
          child: FutureBuilder<List<Surah>>(
            future: _surahFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    color: primary,
                    strokeWidth: 2,
                  ),
                );
              }

              final all = snapshot.data!;
              final filtered = _searchQuery.isEmpty
                  ? all
                  : all
                        .where(
                          (s) =>
                              (s.namaLatin?.toLowerCase().contains(
                                    _searchQuery,
                                  ) ??
                                  false) ||
                              (s.nama?.contains(_searchQuery) ?? false) ||
                              (s.arti?.toLowerCase().contains(_searchQuery) ??
                                  false),
                        )
                        .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, color: text, size: 52),
                      const SizedBox(height: 12),
                      Text(
                        'Natija topilmadi',
                        style: GoogleFonts.poppins(
                          color: text,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '"$_searchQuery" bo\'yicha sura yo\'q',
                        style: GoogleFonts.poppins(
                          color: text,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                  height: 1,
                  indent: 72,
                ),
                itemBuilder: (context, index) => _surahItem(
                  context: context,
                  surah: filtered[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _surahItem({required Surah surah, required BuildContext context}) {
    final isMadina = surah.tempatTurun?.index == 1;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        BlocProvider.of<DisableSuraBloc>(context).add(StartDisableSuraEvent());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              noSurat: surah.nomor!,
              suratName: surah.nama!,
              suratNameLatin: surah.namaLatin!,
              location: surah.tempatTurun!.index,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Number badge
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset('assets/svgs/nomor-surah.svg'),
                SizedBox(
                  height: 36,
                  width: 36,
                  child: Center(
                    child: Text(
                      '${surah.nomor}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Name + info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.namaLatin!,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${surah.jumlahAyat} Oyat',
                        style: GoogleFonts.poppins(
                          color: text,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isMadina
                              ? Colors.green.withValues(alpha: 0.13)
                              : Colors.orange.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isMadina ? 'Madina' : 'Makka',
                          style: GoogleFonts.poppins(
                            color: isMadina
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arabic name
            Text(
              surah.nama!,
              style: GoogleFonts.amiri(
                color: primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
