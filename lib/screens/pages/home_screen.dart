import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:sajda_app/bloc_state_manegment/namoz_vaqtlari/namoz_vaqtlari_bloc.dart';
import 'package:sajda_app/bloc_state_manegment/theme_bloc/theme_mode_bloc.dart';
import 'package:sajda_app/models/namoz_time_model.dart';
import 'package:sajda_app/screens/pages/about.dart';
import 'package:sajda_app/screens/pages/map_screen.dart';
import 'package:sajda_app/screens/pages/murojat.dart';
import 'package:sajda_app/screens/tabs/duolar.dart';
import 'package:sajda_app/screens/tabs/hadislar.dart';
import 'package:sajda_app/screens/tabs/suralar.dart';
import 'package:sajda_app/screens/pages/namoz_tracker.dart';
import 'package:sajda_app/services/location_prefs.dart';
import 'package:sajda_app/services/notification_service/notification_service.dart';
import 'package:sajda_app/utils/uinversal_update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String locationCity = 'Toshkent';
  bool _notifEnabled = true;

  @override
  void initState() {
    super.initState();
    LocationPrefs.getCity().then((city) {
      if (mounted) setState(() => locationCity = city);
    });
    NotificationService.isEnabled().then((v) {
      if (mounted) setState(() => _notifEnabled = v);
    });
    // Ekran chizilгач yangilanishni tekshiramiz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateManager().checkAndPrompt(context);
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notifEnabled = value);
    final state = context.read<NamozVaqtlariBloc>().state;
    final time =
        state is SuccesNamozVaqtlariState ? state.time : null;
    await NotificationService().applyEnabled(value, time: time);
    if (!mounted) return;
    _showSnackBar(
      value ? 'Namoz eslatmalari yoqildi' : 'Namoz eslatmalari o‘chirildi',
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
          ),
          backgroundColor: primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                  child: _NextPrayerCountdown(
                    times: state.time.times,
                    isDark: isDark,
                  ),
                ),
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                  child: _buildRamadanRow(
                    _formatTime(state.time.times.bomdod.toString()),
                    _formatTime(state.time.times.shom.toString()),
                    isDark,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _buildTrackerBanner(isDark),
                ),
              ] else if (state is FailureNamozVaqtlariState) ...[
                _buildPrayerError(context, state.message, isDark),
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

  Widget _buildPrayerError(
    BuildContext context,
    String message,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121931) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: orange.withValues(alpha: 0.35)),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, color: orange, size: 34),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Namoz vaqtlarini yuklab bo‘lmadi',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: text),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () => _retryPrayerTimes(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Qayta urinish',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retryPrayerTimes(BuildContext context) async {
    final region = await LocationPrefs.getRegion();
    if (!context.mounted) return;
    context.read<NamozVaqtlariBloc>().add(GetNamozVaqtiEvent(region));
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

  Widget _buildTrackerBanner(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NamozTrackerScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF6A1FA0), Color(0xFF3A1272)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Namozlarim',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Bugungi namozlaringizni belgilang',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white70,
              ),
            ],
          ),
        ),
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
            Icons.check_circle_outline_rounded,
            'Namozlarim',
            isDark,
            subtitle: 'O‘qigan namozlaringizni belgilang',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NamozTrackerScreen()),
              );
            },
          ),
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

          // Bildirishnoma toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121931) : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Namoz eslatmalari',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Switch(
                    value: _notifEnabled,
                    activeColor: primary,
                    onChanged: (v) => _toggleNotifications(v),
                  ),
                ],
              ),
            ),
          ),

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
            child: FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.data?.version ?? '';
                return Text(
                  version.isEmpty ? 'Versiya: —' : 'Versiya: $version',
                  style: GoogleFonts.poppins(color: text, fontSize: 11),
                  textAlign: TextAlign.center,
                );
              },
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

// ─── Keyingi namozgacha countdown ────────────────────────────────────────────

/// Har soniyada yangilanib, keyingi namozgacha qolgan vaqtni ko'rsatadi.
/// O'z Timer'ini boshqaradi — ota-ekranni qayta chizmaydi.
class _NextPrayerCountdown extends StatefulWidget {
  const _NextPrayerCountdown({required this.times, required this.isDark});

  final Times times;
  final bool isDark;

  @override
  State<_NextPrayerCountdown> createState() => _NextPrayerCountdownState();
}

class _NextPrayerCountdownState extends State<_NextPrayerCountdown> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// "HH:MM" ni bugungi DateTime'ga aylantiradi.
  DateTime? _todayAt(String raw) {
    final t = raw.trim();
    final parts = t.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  /// Keyingi namoz nomi va ungacha qolgan vaqt.
  (String, Duration)? _next() {
    final now = DateTime.now();
    final list = <(String, String)>[
      ('Bomdod', widget.times.bomdod),
      ('Peshin', widget.times.peshin),
      ('Asr', widget.times.asr),
      ('Shom', widget.times.shom),
      ('Xufton', widget.times.xufton),
    ];

    for (final e in list) {
      final dt = _todayAt(e.$2);
      if (dt != null && dt.isAfter(now)) {
        return (e.$1, dt.difference(now));
      }
    }
    // Hammasi o'tib bo'lgan — ertangi Bomdod.
    final bomdod = _todayAt(widget.times.bomdod);
    if (bomdod != null) {
      final tomorrow = bomdod.add(const Duration(days: 1));
      return ('Bomdod', tomorrow.difference(now));
    }
    return null;
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final next = _next();
    if (next == null) return const SizedBox.shrink();
    final (name, remaining) = next;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF9055FF), Color(0xFF6A1FA0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keyingi namoz',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11.5,
                ),
              ),
              Text(
                name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'qoldi',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11.5,
                ),
              ),
              Text(
                _fmt(remaining),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
