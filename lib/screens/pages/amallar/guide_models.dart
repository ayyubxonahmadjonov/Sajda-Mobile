/// Amaldagi bitta bosqich (masalan, namozdagi "Ruku").
///
/// [icon] — islomiy SVG ikonka yo'li (assets/svgs/...).
/// [image] ixtiyoriy: rasman tasdiqlangan rasm qo'shilganda
/// `assets/images/...` yo'lini berasiz, aks holda [icon] ko'rsatiladi.
class GuideStep {
  final String title;
  final String text;
  final String icon;
  final String? image;

  const GuideStep({
    required this.title,
    required this.text,
    required this.icon,
    this.image,
  });
}

/// To'liq qo'llanma (masalan, "Namoz o'qish tartibi").
class Guide {
  final String title;
  final String subtitle;
  final String icon;
  final String source;
  final List<GuideStep> steps;

  const Guide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.source,
    required this.steps,
  });
}
