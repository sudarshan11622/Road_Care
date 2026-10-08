import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../Sudarshan/citizen/report_flow_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompactPhone = screenWidth < 360;
    final horizontalPadding = isCompactPhone ? 16.0 : 22.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const RoadCareLogo(),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/admin-login');
                    },
                    child: const Text('Admin'),
                  ),
                ],
              ),
              SizedBox(height: isCompactPhone ? 28 : 54),
              Text(
                'Help make your\nstreets safer.',
                style: TextStyle(
                  fontSize: isCompactPhone ? 28 : 31,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Report road and neighborhood problems in a few simple steps. '
                'You can submit a problem without creating an account.',
                style: TextStyle(
                  color: AppTheme.muted,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Report a problem',
                icon: Icons.add_a_photo_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportFlowScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/phone'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Track my reports'),
              ),
              const SizedBox(height: 28),
              const SectionTitle(title: 'What you can report'),
              const SizedBox(height: 10),
              const _Feature(
                icon: Icons.warning_amber_rounded,
                title: 'Road damage',
                subtitle: 'Potholes, damaged roads and unsafe surfaces',
              ),
              const _Feature(
                icon: Icons.lightbulb_outline,
                title: 'Street lights',
                subtitle: 'Broken or missing lights in public areas',
              ),
              const _Feature(
                icon: Icons.water_drop_outlined,
                title: 'Drainage problems',
                subtitle: 'Open drains, blocked drains and flooding',
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/phone'),
                  child: const Text('Track submitted reports'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.blue.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.blue, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
