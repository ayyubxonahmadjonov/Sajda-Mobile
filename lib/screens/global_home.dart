import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'package:sajda_app/screens/pages/saved_sura.dart';
import 'package:sajda_app/screens/pages/tasbeh.dart';
import 'package:sajda_app/screens/qibla.dart';
import 'pages/home_screen.dart';
import 'pages/amallar/amallar_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    QiblahScreen(),
    AmallarScreen(),
    TasbehScreen(),
    SavedSura(),
  ];

  final _navItems = const [
    _NavItem(icon: 'assets/images/surakitob.png', label: "Qur'on"),
    _NavItem(icon: 'assets/images/compass.png', label: 'Qibla'),
    _NavItem(icon: 'assets/images/water.png', label: 'Amallar'),
    _NavItem(icon: 'assets/images/tasbih.png', label: 'Tasbeh'),
    _NavItem(icon: 'assets/images/bookmark.png', label: 'Saqlangan'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildNavBar(isDark),
    );
  }

  Widget _buildNavBar(bool isDark) {
    final bg = isDark ? const Color(0xFF121931) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _navButton(i, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(int index, bool isDark) {
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              item.icon,
              color: isSelected ? primary : text,
              height: 22,
              width: 22,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isSelected ? primary : text,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
