import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'asmaul_husna_data.dart';

/// Allohning 99 go'zal ismi — qidiruvli ro'yxat.
class AsmaulHusnaScreen extends StatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  State<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends State<AsmaulHusnaScreen> {
  String _query = '';

  List<AsmaName> get _filtered {
    if (_query.trim().isEmpty) return asmaulHusna;
    final q = _query.toLowerCase();
    return asmaulHusna
        .where((a) =>
            a.latin.toLowerCase().contains(q) ||
            a.meaning.toLowerCase().contains(q) ||
            a.arabic.contains(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? Colors.white : Colors.black87;
    final list = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Asmaul Husna',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: onBg),
        ),
        iconTheme: IconThemeData(color: onBg),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Allohning 99 go‘zal ismi va ma‘nolari',
              style: GoogleFonts.poppins(fontSize: 12.5, color: text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.poppins(color: onBg, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Qidirish (ism yoki ma‘no)...',
                hintStyle: GoogleFonts.poppins(color: text, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: text),
                filled: true,
                fillColor: isDark ? gray : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'Hech narsa topilmadi',
                      style: GoogleFonts.poppins(color: text),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _nameCard(list[i], isDark, onBg),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _nameCard(AsmaName a, bool isDark, Color onBg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? gray : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 42,
            width: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${a.number}',
              style: GoogleFonts.poppins(
                color: primary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.latin,
                  style: GoogleFonts.poppins(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  a.meaning,
                  style: GoogleFonts.poppins(fontSize: 12.5, color: text),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            a.arabic,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.notoNaskhArabic(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}
