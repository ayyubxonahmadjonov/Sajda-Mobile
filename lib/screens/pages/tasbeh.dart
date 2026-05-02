import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:vibration/vibration.dart';

class TasbehScreen extends StatefulWidget {
  const TasbehScreen({super.key});

  @override
  State<TasbehScreen> createState() => _TasbehScreenState();
}

class _TasbehScreenState extends State<TasbehScreen>
    with SingleTickerProviderStateMixin {
  int counter = 0;
  int allCount = 0;
  String txt = '';

  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    Vibration.vibrate(duration: 10);
    _scaleCtrl.forward().then((_) => _scaleCtrl.reverse());

    setState(() {
      if (allCount > 0 && counter >= allCount) {
        counter = 0;
      }
      counter++;
    });
  }

  void _reset() => setState(() => counter = 0);

  double get _progress =>
      allCount > 0 ? (counter / allCount).clamp(0.0, 1.0) : 0.0;

  static const _zikrList = [
    _Zikr(
      title: 'Subhanalloh, Alhamdulillah, Allohu akbar',
      meaning:
          'Allohni poklab yod qilaman, Allohga hamd bo\'lsin, Alloh buyukdir!',
      count: 99,
    ),
    _Zikr(
      title: 'Laa ilaha illallohu Muhammadur Rasululloh',
      meaning:
          'Allohdan o\'zga iloh yo\'q, Muhammad Allohning Rasulidir',
      count: 100,
    ),
    _Zikr(
      title:
          'Ashhadu allaa ilaha illallohu va ashhadu anna Muhammadan abduhu va Rasuluh',
      meaning:
          'Allohdan o\'zga iloh yo\'qligiga, Muhammad uning bandasi va Rasuli ekaniga shohidlik beraman',
      count: 100,
    ),
    _Zikr(
      title:
          'Ashhadu alla ilaha illallohu vahdahu la sharika lah, lahul mulku va lahul hamd',
      meaning:
          'Tanho Allohdan o\'zga sig\'iniladigan iloh yo\'qligiga iqrorman! Allohning sherigi yo\'qdir. Mulk va maqtov Allohgadir.',
      count: 100,
    ),
    _Zikr(
      title:
          'Allohumma inni a\'uzu bika min an ushrika bika shayan va ana a\'lam',
      meaning:
          'Allohim, Sendan o\'zim bilganim holda Senga biror narsani sherik qilishimdan asrashingni so\'rayman.',
      count: 100,
    ),
    _Zikr(
      title: 'Astag\'firulloh, astag\'firulloh, astag\'firulloha ta\'ala',
      meaning:
          'Allohdan gunohlarimni kechishini so\'rayman (3 marta). Alloh taolodan hamma gunohlarimni kechishini so\'rayman.',
      count: 100,
    ),
    _Zikr(
      title:
          'Subhanalloh val hamdu lillah va la ilaha illallohu vallohu akbar',
      meaning:
          'Allohning aybi yo\'q. Maqtov Allohgadir. Allohdan o\'zga iloh yo\'q! Alloh ulug\'dir.',
      count: 100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF040C23), Color(0xFF121931)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7F4FF), Colors.white],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Tasbeh',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (allCount > 0)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          key: ValueKey(counter),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _progress >= 1.0
                                ? Colors.green.withValues(alpha: 0.15)
                                : primary.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$counter / $allCount',
                            style: GoogleFonts.poppins(
                              color: _progress >= 1.0
                                  ? Colors.green[600]
                                  : primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Active zikr card
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: txt.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2B5E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.07),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            txt,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
              ),

              const Spacer(),

              // Progress arc + counter button
              Stack(
                alignment: Alignment.center,
                children: [
                  // Progress arc (slightly larger circle)
                  CustomPaint(
                    size: const Size(230, 230),
                    painter: _ArcPainter(
                      progress: _progress,
                      arcColor:
                          _progress >= 1.0 ? Colors.green : primary,
                      bgColor: isDark
                          ? const Color(0xFF1E2B5E)
                          : Colors.grey.shade200,
                    ),
                  ),
                  // Tap button
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: GestureDetector(
                      onTap: _onTap,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _progress >= 1.0
                                ? [
                                    Colors.green.shade300,
                                    Colors.green.shade700,
                                  ]
                                : const [
                                    Color(0xFFDF98FA),
                                    Color(0xFF9055FF),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_progress >= 1.0
                                      ? Colors.green
                                      : primary)
                                  .withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$counter',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 54,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              _progress >= 1.0 ? 'Tugadi!' : 'Bosing',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: primary.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _reset,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: primary,
                          size: 20,
                        ),
                        label: Text(
                          'Qayta boshlash',
                          style: GoogleFonts.poppins(
                            color: primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _showZikrSheet(isDark),
                        icon: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'Zikr tanlash',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showZikrSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1B4B) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Zikr va Duolar',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _zikrList.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? Colors.white12 : Colors.black12,
                  indent: 20,
                ),
                itemBuilder: (ctx, i) {
                  final z = _zikrList[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    title: Text(
                      z.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        z.meaning,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: text,
                        ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${z.count}×',
                        style: GoogleFonts.poppins(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        allCount = z.count;
                        txt = z.title;
                        counter = 0;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom + 12,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Arc painter ─────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color arcColor;
  final Color bgColor;

  const _ArcPainter({
    required this.progress,
    required this.arcColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 9.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background ring
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..color = bgColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = arcColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.arcColor != arcColor;
}

// ─── Zikr data model ─────────────────────────────────────────────────────────

class _Zikr {
  final String title;
  final String meaning;
  final int count;
  const _Zikr({
    required this.title,
    required this.meaning,
    required this.count,
  });
}
