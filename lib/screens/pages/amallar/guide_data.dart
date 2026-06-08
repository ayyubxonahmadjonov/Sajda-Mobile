import 'guide_models.dart';

/// Barcha qo'llanmalar matni rasman tasdiqlangan manbadan olingan:
/// O'zbekiston Musulmonlari Idorasi — muslim.uz (Hanafiy mazhabi).
///
/// Namoz o'qish tartibi:
///   https://muslim.uz/uz/e/post/23602-namoz-saboqlari-namoz-o-qish-tartibi-audio
/// G'usl va uning farzlari:
///   https://muslim.uz/uz/e/post/23907-namoz-saboqlari-g-usl-va-uning-farzlari-audio
///
/// Ikonkalar: HugeIcons (islomiy to'plam) — assets/svgs/g_*.svg

const String _svg = 'assets/svgs/';
const String _source = 'Manba: O‘zbekiston Musulmonlari Idorasi (muslim.uz)';

/// Namoz o'qish tartibi — bomdod namozining ikki rakat farzi misolida.
const Guide namozGuide = Guide(
  title: 'Namoz o‘qish tartibi',
  subtitle: 'Ikki rakat farz namoz misolida',
  icon: '${_svg}g_salah.svg',
  source: _source,
  steps: [
    GuideStep(
      title: 'Niyat',
      icon: '${_svg}g_kaaba-01.svg',
      text:
          'Qiblaga (Ka’ba tarafiga) yuzlaniladi. «Shu vaqt bomdod namozining '
          'farzini xolis Alloh taolo uchun o‘qishni niyat qildim» deb ko‘ngildan '
          'o‘tkaziladi.',
    ),
    GuideStep(
      title: 'Takbiri tahrima',
      icon: '${_svg}g_hand-prayer.svg',
      text:
          'Ikki qo‘lning bosh barmoqlari quloq yumshog‘i barobarida ko‘tarilib, '
          '«Allohu akbar» deb namozga kiriladi. So‘ng o‘ng qo‘l chap qo‘l ustiga '
          'qo‘yilib, kindik ostida bog‘lanadi (qiyom holati).',
    ),
    GuideStep(
      title: 'Sano',
      icon: '${_svg}g_quran-03.svg',
      text:
          'Ichida sano o‘qiladi:\n\n«Subhanakallohumma va bihamdika, va '
          'tabarakasmuka, va ta’ala jadduka, va la ilaha g‘ayruk».',
    ),
    GuideStep(
      title: 'Qiroat',
      icon: '${_svg}g_quran-01.svg',
      text:
          '«A’uzu billahi minash-shaytonir rojiym, Bismillahir rohmanir rohiym» '
          'deyilib, Fotiha surasi o‘qiladi. So‘ngra «omiyn» deb, biror zam '
          '(qo‘shimcha) sura yoki oyatlar o‘qiladi.',
    ),
    GuideStep(
      title: 'Ruku',
      icon: '${_svg}g_ruku.svg',
      text:
          '«Allohu akbar» deb belni egib, qo‘llar tizzaga qo‘yiladi va kamida uch '
          'marta «Subhana robbiyal aziym» deyiladi.',
    ),
    GuideStep(
      title: 'Qavma',
      icon: '${_svg}g_muslim.svg',
      text:
          'Rukudan «Sami’allohu liman hamidah» deb tik turiladi va tik turgan '
          'holda «Robbana va lakal hamd» deyiladi.',
    ),
    GuideStep(
      title: 'Birinchi sajda',
      icon: '${_svg}g_salah.svg',
      text:
          '«Allohu akbar» deb sajdaga boriladi: avval tizza, so‘ng qo‘llar, '
          'so‘ng yuz yerga qo‘yiladi. Kamida uch marta «Subhana robbiyal a’la» '
          'deyiladi.',
    ),
    GuideStep(
      title: 'Jalsa',
      icon: '${_svg}g_prayer-rug-02.svg',
      text:
          '«Allohu akbar» deb sajdadan bosh ko‘tarib, ikki sajda orasida bir oz '
          'tinch o‘tiriladi.',
    ),
    GuideStep(
      title: 'Ikkinchi sajda',
      icon: '${_svg}g_salah.svg',
      text:
          'Yana «Allohu akbar» deb sajdaga boriladi va kamida uch marta '
          '«Subhana robbiyal a’la» deyiladi. Shu bilan birinchi rakat tugaydi.',
    ),
    GuideStep(
      title: 'Ikkinchi rakat',
      icon: '${_svg}g_salah-time.svg',
      text:
          '«Allohu akbar» deb qiyomga turiladi. Sanosiz, to‘g‘ridan Fotiha va zam '
          'sura o‘qilib, ruku va ikki sajda birinchi rakatdagidek takrorlanadi.',
    ),
    GuideStep(
      title: 'Qa’da — Attahiyot',
      icon: '${_svg}g_tasbih.svg',
      text:
          'Ikkinchi sajdadan so‘ng o‘tirilib attahiyot o‘qiladi:\n\n'
          '«At-tahiyyatu lillahi vas-solavatu vat-toyyibat, assalamu alayka '
          'ayyuhan-nabiyyu va rohmatullohi va barakatuh, assalamu alayna va ala '
          'ibadillahis-solihiyn. Ashhadu alla ilaha illalloh va ashhadu anna '
          'Muhammadan abduhu va rasuluh».',
    ),
    GuideStep(
      title: 'Salovat',
      icon: '${_svg}g_the-prophets-mosque.svg',
      text:
          '«Allohumma solli ala Muhammadin va ala ali Muhammad, kama sollayta ala '
          'Ibrohiyma va ala ali Ibrohiym, innaka hamiydun majiyd. Allohumma barik '
          'ala Muhammadin va ala ali Muhammad, kama barakta ala Ibrohiyma va ala '
          'ali Ibrohiym, innaka hamiydun majiyd».',
    ),
    GuideStep(
      title: 'Duo',
      icon: '${_svg}g_allah.svg',
      text:
          'So‘ng duo o‘qiladi:\n\n«Robbana atina fid-dunya hasanatan va fil-axirati '
          'hasanatan va qina azaban-nar».',
    ),
    GuideStep(
      title: 'Salom',
      icon: '${_svg}g_waving-hand-01.svg',
      text:
          'Avval o‘ng yelka tomonga, so‘ng chap yelka tomonga yuz burib '
          '«Assalamu alaykum va rohmatulloh» deyiladi. Shu bilan namoz tugaydi.',
    ),
  ],
);

/// G'usl (cho'milish) olish tartibi va farzlari.
const Guide guslGuide = Guide(
  title: 'G‘usl olish tartibi',
  subtitle: 'To‘liq tahorat va uning farzlari',
  icon: '${_svg}g_shower-head.svg',
  source: _source,
  steps: [
    GuideStep(
      title: 'Niyat',
      icon: '${_svg}g_hand-prayer.svg',
      text:
          '«Bismillahir rohmanir rohiym» deb, g‘usl qilishni (hadasdan poklanishni) '
          'niyat qilinadi.',
    ),
    GuideStep(
      title: 'Qo‘llarni yuvish',
      icon: '${_svg}g_hand-sanitizer.svg',
      text: 'Avval ikki qo‘l bilaklargacha yuviladi.',
    ),
    GuideStep(
      title: 'Najosatni yuvish',
      icon: '${_svg}g_clean.svg',
      text:
          'Avrat (uyat joylar) va badandagi najosat — masalan, maniy izi bo‘lsa — '
          'yuvib tozalanadi.',
    ),
    GuideStep(
      title: 'Tahorat olish',
      icon: '${_svg}g_wudu.svg',
      text:
          'Namozga olinadigan tahorat kabi to‘liq tahorat olinadi. (Oyoq tagida suv '
          'yig‘ilib qolsa, oyoqlar oxirida yuviladi.)',
    ),
    GuideStep(
      title: 'Og‘iz va burunni chayish',
      icon: '${_svg}g_droplet.svg',
      text:
          'Og‘izga suv olib, tomoqqa yetkazib g‘arg‘ara qilib chayiladi; burunga '
          'suv tortib chayiladi. Bu g‘uslning farzlaridandir.',
    ),
    GuideStep(
      title: 'Boshga suv quyish',
      icon: '${_svg}g_shower-head.svg',
      text: 'Boshga uch marta suv quyilib, soch tagigacha suv yetkaziladi.',
    ),
    GuideStep(
      title: 'O‘ng yelkaga suv quyish',
      icon: '${_svg}g_rain-drop.svg',
      text: 'So‘ngra o‘ng yelkaga uch marta suv quyiladi.',
    ),
    GuideStep(
      title: 'Chap yelkaga suv quyish',
      icon: '${_svg}g_rain-drop.svg',
      text: 'So‘ngra chap yelkaga uch marta suv quyiladi.',
    ),
    GuideStep(
      title: 'Butun badanni yuvish',
      icon: '${_svg}g_water-pump.svg',
      text:
          'Butun badan ishqalab yuviladi. Ignaning uchichalik quruq joy qolsa ham '
          'g‘usl to‘liq bo‘lmaydi. G‘uslning uch farzi: og‘izni chayish, burunni '
          'chayish va butun tanani yuvish.',
    ),
  ],
);

/// Tab'da ko'rsatiladigan barcha amallar ro'yxati tartibi.
const List<Guide> allGuides = [namozGuide, guslGuide];
