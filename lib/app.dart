import 'dart:async';

import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/phone_login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'Sudarshan/citizen/citizen_shell.dart';
import 'Moria/admin/admin_login_screen.dart';
import 'Moria/admin/admin_shell.dart';

class RoadCareApp extends StatefulWidget {
  const RoadCareApp({super.key});

  @override
  State<RoadCareApp> createState() => _RoadCareAppState();
}

class _RoadCareAppState extends State<RoadCareApp> {
  late final AppState state;

  @override
  void initState() {
    super.initState();
    state = AppState()..load();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: Builder(
        builder: (context) {
          final session = AppScope.of(context);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RoadCare',
            theme: AppTheme.light.copyWith(),
            darkTheme: AppTheme.darkTheme.copyWith(),
            themeMode: session.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: media.textScaler.clamp(maxScaleFactor: 1.1),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxContentWidth =
                        constraints.maxWidth >= 1024 ? 1120.0 : 760.0;
                    final content = child ?? const SizedBox.shrink();

                    if (constraints.maxWidth <= 600) {
                      return content;
                    }

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        child: content,
                      ),
                    );
                  },
                ),
              );
            },
            home: const SplashScreen(),
            routes: {
              '/welcome': (_) => const WelcomeScreen(),
              '/phone': (_) => const PhoneLoginScreen(),
              '/otp': (_) => const OtpScreen(),
              '/citizen': (_) => const CitizenShell(),
              '/admin-login': (_) => const AdminLoginScreen(),
              '/admin': (_) => const AdminShell(),
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      final route = AppScope.of(context).homeRoute;
      final nextRoute = route == '/' ? '/welcome' : route;
      Navigator.of(context).pushReplacementNamed(nextRoute);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A58E8),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/roadcare_logo.png',
                width: 70,
                height: 70,
              ),
              const SizedBox(height: 24),
              const Text(
                'RoadCare',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Report. Track. Improve.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withValues(alpha: index == 0 ? 1 : 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'A civic infrastructure initiative',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}
