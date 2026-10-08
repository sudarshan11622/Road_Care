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
          final homeScreen = switch (session.homeRoute) {
            '/citizen' => const CitizenShell(),
            '/admin' => const AdminShell(),
            _ => const WelcomeScreen(),
          };

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'RoadCare',
            theme: AppTheme.light.copyWith(useMaterial3: true),
            darkTheme: AppTheme.darkTheme.copyWith(useMaterial3: true),
            themeMode: session.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: media.textScaler.clamp(maxScaleFactor: 1.1),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: media.size.width < 600 ? double.infinity : 430,
                    ),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
            home: homeScreen,
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
