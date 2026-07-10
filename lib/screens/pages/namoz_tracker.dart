import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:sajda_app/services/prayer_tracker.dart';

/// Namoz tracker — o'qilgan namozlarni belgilash, ketma-ketlik (streak) va
/// foydalanuvchi tanlagan "challenge" (necha kunlik) bo'yicha progress.
class NamozTrackerScreen extends StatefulWidget {
  const NamozTrackerScreen({super.key});

  @override
  State<NamozTrackerScreen> createState() => _NamozTrackerScreenState();
}

class _NamozTrackerScreenState extends State<NamozTrackerScreen> {
  final DateTime _today = DateTime.now();

  Set<String> _todayPrayed = {};
  int _streak = 0;
  int _totalDays = 0;
  ({int goalDays, DateTime start})? _challenge;
  int _challengeDone = 0;
  List<int> _last7 = List.filled(7, 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final todayPrayed = await PrayerTracker.getPrayed(_today);
    final streak = await PrayerTracker.currentStreak();
    final total = await PrayerTracker.totalCompleteDays();
    final challenge = await PrayerTracker.getChallenge();
    final done = challenge == null
        ? 0
        : await PrayerTracker.challengeCompletedDays(challenge.start);

    final last7 = <int>[];
    for (int i = 6; i >= 0; i--) {
      final day = _today.subtract(Duration(days: i));
      final prayed = await PrayerTracker.getPrayed(day);
      last7.add(prayed.length);
    }

    if (!mounted) return;
    setState(() {
      _todayPrayed = todayPrayed;
      _streak = streak;
      _totalDays = total;
      _challenge = challenge;
      _challengeDone = done;
      _last7 = last7;
      _loading = false;
    });
  }

  Future<void> _togglePrayer(String key) async {
    final updated = await PrayerTracker.toggle(_today, key);
    setState(() => _todayPrayed = updated);
    // Streak / progress / tarixni yangilaymiz.
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Namozlarim',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: onBg,
          ),
        ),
        iconTheme: IconThemeData(color: onBg),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _statsRow(isDark),
                const SizedBox(height: 16),
                _challengeCard(isDark, onBg),
                const SizedBox(height: 20),
                Text(
                  'Bugun',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatToday(),
                  style: GoogleFonts.poppins(fontSize: 12.5, color: text),
                ),
                const SizedBox(height: 12),
                ...PrayerTracker.prayerKeys.map((k) => _prayerTile(k, isDark, onBg)),
                const SizedBox(height: 20),
                Text(
                  'So‘nggi 7 kun',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 12),
                _weekRow(isDark, onBg),
              ],
            ),
    );
  }

  // ─── Stats (streak + total) ────────────────────────────────────────────────

  Widget _statsRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            isDark,
            icon: Icons.local_fire_department_rounded,
            iconColor: orange,
            value: '$_streak',
            label: 'kun ketma-ket',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            isDark,
            icon: Icons.verified_rounded,
            iconColor: primary,
            value: '$_totalDays',
            label: 'to‘liq kun',
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? gray : Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 11, color: text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Challenge ─────────────────────────────────────────────────────────────

  Widget _challengeCard(bool isDark, Color onBg) {
    final challenge = _challenge;
    if (challenge == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A1FA0), Color(0xFF3A1272)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge boshlang‘',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Necha kun ketma-ket 5 vaqt namozni to‘liq o‘qishga ahd qilasiz?',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _goalChip(7),
                _goalChip(30),
                _goalChip(40),
                _goalChip(66),
                _customGoalChip(),
              ],
            ),
          ],
        ),
      );
    }

    final progress = (_challengeDone / challenge.goalDays).clamp(0.0, 1.0);
    final remaining = (challenge.goalDays - _challengeDone).clamp(0, 999);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? gray : Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          SizedBox(
            height: 74,
            width: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 74,
                  width: 74,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 7,
                    backgroundColor: primary.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(primary),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: onBg,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${challenge.goalDays} kunlik challenge',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: onBg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_challengeDone / ${challenge.goalDays} kun bajarildi',
                  style: GoogleFonts.poppins(fontSize: 12.5, color: text),
                ),
                Text(
                  remaining == 0
                      ? 'Barakalla! Maqsadga yetdingiz 🎉'
                      : 'Yana $remaining kun qoldi',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: remaining == 0 ? primary : text,
                    fontWeight:
                        remaining == 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _confirmCancelChallenge,
                  child: Text(
                    'Bekor qilish',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalChip(int days) {
    return GestureDetector(
      onTap: () => _startChallenge(days),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: Text(
          '$days kun',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _customGoalChip() {
    return GestureDetector(
      onTap: _askCustomGoal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF6A1FA0)),
            const SizedBox(width: 5),
            Text(
              'Boshqa',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6A1FA0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChallenge(int days) async {
    await PrayerTracker.startChallenge(days);
    await _load();
  }

  Future<void> _askCustomGoal() async {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? gray : Colors.white,
        title: Text(
          'Necha kunlik challenge?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Masalan: 21',
            suffixText: 'kun',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor'),
          ),
          TextButton(
            onPressed: () {
              final n = int.tryParse(controller.text.trim());
              Navigator.pop(ctx, (n != null && n > 0) ? n : null);
            },
            child: const Text('Boshlash'),
          ),
        ],
      ),
    );
    if (days != null) await _startChallenge(days);
  }

  Future<void> _confirmCancelChallenge() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? gray : Colors.white,
        title: Text(
          'Challenge bekor qilinsinmi?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Belgilangan namozlar saqlanib qoladi, faqat challenge maqsadi o‘chadi.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Yo‘q'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ha'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await PrayerTracker.cancelChallenge();
      await _load();
    }
  }

  // ─── Today's prayers ───────────────────────────────────────────────────────

  Widget _prayerTile(String key, bool isDark, Color onBg) {
    final done = _todayPrayed.contains(key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: done
            ? primary.withValues(alpha: isDark ? 0.22 : 0.12)
            : (isDark ? gray : Colors.white),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _togglePrayer(key),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: done ? primary : text,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Text(
                  PrayerTracker.prayerNames[key] ?? key,
                  style: GoogleFonts.poppins(
                    fontSize: 15.5,
                    fontWeight: done ? FontWeight.w600 : FontWeight.w500,
                    color: done ? primary : onBg,
                  ),
                ),
                const Spacer(),
                if (done)
                  Text(
                    'o‘qildi',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Weekly history ────────────────────────────────────────────────────────

  Widget _weekRow(bool isDark, Color onBg) {
    const labels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = _today.subtract(Duration(days: 6 - i));
        final count = _last7[i];
        final ratio = count / 5.0;
        final label = labels[(day.weekday - 1) % 7];
        return Column(
          children: [
            SizedBox(
              height: 42,
              width: 42,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 42,
                    width: 42,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 4,
                      backgroundColor: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(
                        count == 5 ? primary : orange,
                      ),
                    ),
                  ),
                  Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: onBg,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: text),
            ),
          ],
        );
      }),
    );
  }

  String _formatToday() {
    const months = [
      'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun',
      'iyul', 'avgust', 'sentabr', 'oktabr', 'noyabr', 'dekabr',
    ];
    return '${_today.day} ${months[_today.month - 1]}, ${_today.year}';
  }
}
