import 'package:flutter/material.dart';
import '../../app.dart';
import '../../widgets/common.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> verify() async {
    if (controller.text.trim() != '1234') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo OTP is 1234')),
      );
      return;
    }
    final phone = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    await AppScope.of(context).loginCitizen(phone);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/citizen', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify number')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const RoadCareLogo(markSize: 40, fontSize: 20),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Enter the code',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Use the 4-digit verification code sent to your phone.',
                style: TextStyle(color: Color(0xFF667085)),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '••••',
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(label: 'Verify & continue', onPressed: verify),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Demo OTP: 1234',
                  style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
