import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/constants/globals.dart';
import 'bloc_state_manegment/disableSura/disable_sura_bloc.dart';
import 'bloc_state_manegment/namoz_vaqtlari/namoz_vaqtlari_bloc.dart';
import 'bloc_state_manegment/savedSuraBloc/get_sura_name_with_isar_bloc.dart';
import 'bloc_state_manegment/theme_bloc/theme_mode_bloc.dart';
import 'screens/splash_screen.dart';
import 'services/iser_service/hive_service.dart';
import 'services/location_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  final savedRegion = await LocationPrefs.getRegion();
  runApp(MyApp(initialRegion: savedRegion));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialRegion});

  final String initialRegion;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetSuraNameWithIsarBloc()),
        BlocProvider(create: (context) => DisableSuraBloc()),
        BlocProvider(
          create: (context) => ThemeModeBloc()..add(SetDarkThemeEvent()),
        ),
        BlocProvider(
          create:
              (context) =>
                  NamozVaqtlariBloc()
                    ..add(GetNamozVaqtiEvent(widget.initialRegion)),
        ),
      ],
      child: BlocBuilder<ThemeModeBloc, ThemeModeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Sajda Mobile App',
            themeMode:
                state is SetLightThemeModeState
                    ? ThemeMode.light
                    : ThemeMode.dark,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            darkTheme: ThemeData(
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: gray,
              ),
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF040C23),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF040C23),
              ),
            ),
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
//flutter pub run build_runner build
//dart run build_runner build