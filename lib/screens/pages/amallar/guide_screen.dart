import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sajda_app/app/constants/globals.dart';
import 'guide_models.dart';

/// Har qanday amal (namoz, g'usl, ...) uchun bosqichma-bosqich ko'rsatkich.
class GuideScreen extends StatefulWidget {
  final Guide guide;
  const GuideScreen({super.key, required this.guide});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = _current + delta;
    if (next < 0 || next >= widget.guide.steps.length) return;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? Colors.white : Colors.black;
    final steps = widget.guide.steps;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: onBg, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.guide.title,
          style: GoogleFonts.poppins(
            color: onBg,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Bosqich hisoblagichi: 3 / 14
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${_current + 1} / ${steps.length}',
                style: GoogleFonts.poppins(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: steps.length,
                onPageChanged: (v) => setState(() => _current = v),
                itemBuilder: (_, i) => _stepView(steps[i], onBg),
              ),
            ),
            _dots(steps.length),
            _navRow(isDark, onBg),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 24, right: 24),
              child: Text(
                widget.guide.source,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: text,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepView(GuideStep step, Color onBg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: onBg,
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 20),
          _visual(step),
          const SizedBox(height: 24),
          Text(
            step.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: onBg,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Rasm berilgan bo'lsa rasmni, aks holda ikonkani ko'rsatadi.
  /// (Rasman tasdiqlangan rasm qo'shilganda GuideStep.image to'ldiriladi.)
  Widget _visual(GuideStep step) {
    final size = MediaQuery.of(context).size.width * 0.5;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: step.image != null
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(step.image!, fit: BoxFit.contain),
            )
          : SvgPicture.asset(
              step.icon,
              width: size * 0.46,
              height: size * 0.46,
              colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
            ),
    );
  }

  Widget _dots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == _current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 7,
          width: active ? 18 : 7,
          decoration: BoxDecoration(
            color: active ? primary : primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _navRow(bool isDark, Color onBg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _arrow(Icons.keyboard_arrow_left, _current > 0, () => _go(-1)),
          _arrow(
            Icons.keyboard_arrow_right,
            _current < widget.guide.steps.length - 1,
            () => _go(1),
          ),
        ],
      ),
    );
  }

  Widget _arrow(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? primary.withValues(alpha: 0.14)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 32,
          color: enabled ? primary : text.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
