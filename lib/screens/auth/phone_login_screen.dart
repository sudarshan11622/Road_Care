import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void next() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    Navigator.pushNamed(
      context,
      '/otp',
      arguments: controller.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track your reports')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        child: Form(
          key: formKey,
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
              const Text(
                'What’s your number?',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We’ll send a one-time code to find your submitted reports.',
                style: TextStyle(color: AppTheme.muted, height: 1.4),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixText: '+91  ',
                  labelText: 'Mobile number',
                ),
                validator: (value) {
                  final v = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (v.length < 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
              const Spacer(),
              PrimaryButton(label: 'Next', onPressed: next),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Demo mode: any valid number works.',
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
