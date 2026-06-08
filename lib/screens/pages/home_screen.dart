import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:sajda_app/bloc_state_manegment/namoz_vaqtlari/namoz_vaqtlari_bloc.dart';
import 'package:sajda_app/bloc_state_manegment/theme_bloc/theme_mode_bloc.dart';
import 'package:sajda_app/screens/pages/about.dart';
import 'package:sajda_app/screens/pages/map_screen.dart';
import 'package:sajda_app/screens/pages/murojat.dart';
import 'package:sajda_app/screens/tabs/duolar.dart';
import 'package:sajda_app/screens/tabs/hadislar.dart';
import 'package:sajda_app/screens/tabs/suralar.dart';
import 'package:sajda_app/services/location_prefs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String locationCity = 'Toshkent';

  @override
  void initState() {
    super.initState();
    LocationPrefs.getCity().then((city) {
      if (mounted) setState(() => locationCity = city);
    });
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '--:--';
    return time.length >= 5 ? time.substring(0, 5) : time;
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Assalamu alaykum';
    if (h < 12) return 'Xayrli tong';
    if (h < 17) return 'Xayrli kun';
    if (h < 21) return 'Xayrli kech';
    return 'Assalamu alaykum';
  }

  bool _isCurrentPrayerSlot(int index) {
    final h = DateTime.now().hour;
    if (index == 0 && h >= 4 && h < 6) return true;
    if (index == 1 && h >= 6 && h < 8) return true;
    if (index == 2 && h >= 12 && h < 15) return true;
    if (index == 3 && h >= 15 && h < 18) return true;
    if (index == 4 && h >= 18 && h < 21) return true;
    if (index == 5 && (h >= 21 || h < 4)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(isDark),
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(
                    child: _buildPrayerSection(context, isDark),
                  ),
                  SliverAppBar(
                    pinned: true,
                    primary: false,
                    elevation: 0,
                    toolbarHeight: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor:
                        isDark ? const Color(0xFF040C23) : Colors.white,
                    shape: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.black.withValues(alpha: 0.07),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(50),
                      child: _buildTabBar(isDark),
                    ),
                  ),
                ],
                body: const TabBarView(
                  children: [SurahTab(), DuolarScreen(), HadislarScreen()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A1FA0), Color(0xFF3A1272)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 12, 14),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _greeting(),
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Muhammad (s.a.v.)',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<ThemeModeBloc, ThemeModeState>(
                builder: (context, state) {
                  final isDarkMode = state is SetDarkThemeModeState;
                  return GestureDetector(
                    onTap: () {
                      if (isDarkMode) {
                        BlocProvider.of<ThemeModeBloc>(
                          context,
                        ).add(SetLightThemeEvent());
                      } else {
                        BlocProvider.of<ThemeModeBloc>(
                          context,
                        ).add(SetDarkThemeEvent());
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Prayer Times Section ────────────────────────────────────────────────

  Widget _buildPrayerSection(BuildContext outerContext, bool isDark) {
    return BlocBuilder<NamozVaqtlariBloc, NamozVaqtlariState>(
      builder: (context, state) {
        final bgColor =
            isDark ? const Color(0xFF040C23) : const Color(0xFFF7F4FF);

        return Container(
          color: bgColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Text(
                      'Namoz vaqtlari',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showCityBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: primary,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              locationCity,
                              style: GoogleFonts.poppins(
                                color: primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.expand_more_rounded,
                              color: primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Prayer cards or loading
              if (state is SuccesNamozVaqtlariState) ...[
                SizedBox(
                  height: 104,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _prayerCard(
                        'Bomdod',
                        _formatTime(state.time.times.bomdod.toString()),
                        Icons.nightlight_round,
                        isDark,
                        0,
                      ),
                      _prayerCard(
                        'Quyosh',
                        _formatTime(state.time.times.quyosh.toString()),
                        Icons.wb_sunny_outlined,
                        isDark,
                        1,
                      ),
                      _prayerCard(
                        'Peshin',
                        _formatTime(state.time.times.peshin.toString()),
                        Icons.wb_sunny_rounded,
                        isDark,
                        2,
                      ),
                      _prayerCard(
                        'Asr',
                        _formatTime(state.time.times.asr.toString()),
                        Icons.wb_twilight_rounded,
                        isDark,
                        3,
                      ),
                      _prayerCard(
                        'Shom',
                        _formatTime(state.time.times.shom.toString()),
                        Icons.nights_stay_outlined,
                        isDark,
                        4,
                      ),
                      _prayerCard(
                        'Xufton',
                        _formatTime(state.time.times.xufton.toString()),
                        Icons.bedtime_rounded,
                        isDark,
                        5,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: _buildRamadanRow(
                    _formatTime(state.time.times.bomdod.toString()),
                    _formatTime(state.time.times.shom.toString()),
                    isDark,
                  ),
                ),
              ] else ...[
                const SizedBox(
                  height: 130,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _prayerCard(
    String name,
    String time,
    IconData icon,
    bool isDark,
    int index,
  ) {
    final isActive = _isCurrentPrayerSlot(index);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDF98FA), Color(0xFF9055FF)],
              )
            : null,
        color: isActive
            ? null
            : (isDark ? const Color(0xFF121931) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? primary.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : (isDark ? text : Colors.grey[500]),
            size: 18,
          ),
          const SizedBox(height: 5),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isActive ? Colors.white70 : text,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRamadanRow(String saxarlik, String iftorlik, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121931) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.brightness_2_rounded, color: primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saxarlik',
                  style: GoogleFonts.poppins(fontSize: 11, color: text),
                ),
                Text(
                  saxarlik,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Iftorlik',
                  style: GoogleFonts.poppins(fontSize: 11, color: text),
                ),
                Text(
                  iftorlik,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.wb_sunny_rounded, color: orange, size: 18),
        ],
      ),
    );
  }

  // ─── Tab Bar ─────────────────────────────────────────────────────────────

  TabBar _buildTabBar(bool isDark) {
    return TabBar(
      unselectedLabelColor: text,
      labelColor: isDark ? Colors.white : Colors.black87,
      indicatorColor: primary,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: [
        Tab(
          child: Text(
            'Sura',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Tab(
          child: Text(
            'Duolar',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Tab(
          child: Text(
            'Hadislar',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Drawer ──────────────────────────────────────────────────────────────

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF040C23) : Colors.white,
      width: MediaQuery.of(context).size.width * 0.72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6A1FA0), Color(0xFF3A1272)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/islambac.png', height: 70),
                    const SizedBox(height: 12),
                    Text(
                      'Sajda',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Islomiy ilova',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          _drawerTile(
            Icons.mosque_rounded,
            'Masjidlar',
            isDark,
            subtitle: 'Yaqin atrofdagi masjidlar',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MosqueMapPage()),
              );
            },
          ),
          _drawerTile(
            Icons.info_outline_rounded,
            'Ilova haqida',
            isDark,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
          ),
          _drawerTile(
            Icons.mail_outline_rounded,
            'Murojat uchun',
            isDark,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CommentsPage()),
            ),
          ),

          const Spacer(),

          // Theme toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlocBuilder<ThemeModeBloc, ThemeModeState>(
              builder: (context, state) {
                final isDarkMode = state is SetDarkThemeModeState;
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF121931)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _themeBtn(
                        context,
                        Icons.wb_sunny_rounded,
                        "Yorug'",
                        !isDarkMode,
                        () => BlocProvider.of<ThemeModeBloc>(
                          context,
                        ).add(SetLightThemeEvent()),
                      ),
                      _themeBtn(
                        context,
                        Icons.nightlight_round,
                        "Qorong'u",
                        isDarkMode,
                        () => BlocProvider.of<ThemeModeBloc>(
                          context,
                        ).add(SetDarkThemeEvent()),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Versiya: 1.0.7',
              style: GoogleFonts.poppins(color: text, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(
    IconData icon,
    String title,
    bool isDark, {
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.poppins(color: text, fontSize: 11),
            )
          : null,
      trailing: Icon(Icons.chevron_right_rounded, color: text, size: 20),
      onTap: onTap,
    );
  }

  Widget _themeBtn(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : text,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── City bottom sheet ────────────────────────────────────────────────────

  void _showCityBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cities = {
      'Toshkent': 'Toshkent',
      'Andijon': 'Andijon',
      'Buxoro': 'Buxoro',
      "Farg'ona": "Farg'ona",
      'Jizzax': 'Jizzax',
      'Xorazm': 'Xiva',
      'Namangan': 'Namangan',
      'Navoiy': 'Navoiy',
      'Qashqadaryo': 'Qashqadaryo',
      'Samarqand': 'Samarqand',
      'Sirdaryo': 'Sirdaryo',
      'Surxandaryo': 'Surxandaryo',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D1B4B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  Icon(Icons.location_on_rounded, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Viloyatni tanlang',
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
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (ctx, index) {
                  final entry = cities.entries.toList()[index];
                  final isSelected = locationCity == entry.key;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary.withValues(alpha: 0.15)
                            : (isDark
                                  ? const Color(0xFF121931)
                                  : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_city_rounded,
                        color: isSelected ? primary : text,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      entry.key,
                      style: GoogleFonts.poppins(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? primary
                            : (isDark ? Colors.white : Colors.black87),
                        fontSize: 15,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: primary, size: 20)
                        : null,
                    onTap: () {
                      BlocProvider.of<NamozVaqtlariBloc>(
                        context,
                      ).add(GetNamozVaqtiEvent(entry.value));
                      LocationPrefs.save(entry.key, entry.value);
                      setState(() => locationCity = entry.key);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
