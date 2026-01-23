import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sajda_app/screens/spashing.dart';
import 'package:sajda_app/utils/uinversal_update_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../app/constants/globals.dart';
import 'global_home.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    await Future.delayed(Duration.zero);

    await UniversalUpdateService().checkForUpdate(context);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    _navigateUser();
  }

  Future<void> _navigateUser() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('splaw') ?? false;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => status ? const Home() : const Splashing(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          'assets/svgs/bismillah.svg',
          width: MediaQuery.of(context).size.width * 0.6,
          color:
              Theme.of(context).brightness == Brightness.light
                  ? primary
                  : Colors.white,
        ),
      ),
    );
  }
}
