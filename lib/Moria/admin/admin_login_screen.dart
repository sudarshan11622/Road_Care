import 'package:flutter/material.dart';
import '../../app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final email = TextEditingController(text: 'admin@roadcare.app');
  final password = TextEditingController(text: 'admin123');

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (email.text.trim() != 'admin@roadcare.app' || password.text != 'admin123') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use the demo admin credentials shown below.')),
      );
      return;
    }
    await AppScope.of(context).loginAdmin();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/admin', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administration')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const RoadCareLogo(markSize: 40, fontSize: 20),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Welcome back, Admin', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
            const SizedBox(height: 7),
            const Text(
              'Manage citizen reports and RoadCare operations.',
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 25),
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const Spacer(),
            PrimaryButton(label: 'Sign in to dashboard', onPressed: login),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Demo: admin@roadcare.app / admin123',
                style: TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
