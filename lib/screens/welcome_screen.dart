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
    final horizontalPadding = isCompactPhone ? 18.0 : 22.0;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 18, horizontalPadding, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const RoadCareLogo(),
                  const Spacer(),
                  Flexible(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, '/phone'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(92, 40),
                            foregroundColor: AppTheme.text,
                            side: const BorderSide(color: AppTheme.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/admin-login');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Admin Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppTheme.green),
                    SizedBox(width: 6),
                    Text(
                      'No account required',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Help make your\nstreets safer.',
                style: TextStyle(
                  fontSize: isCompactPhone ? 34 : 38,
                  height: 1.02,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.text,
                  letterSpacing: -1.3,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Report potholes, damaged roads, broken streetlights, and other local issues directly to the city team.',
                style: TextStyle(
                  color: AppTheme.muted,
                  height: 1.5,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportFlowScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Report a problem'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/phone'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Already submitted a report? Sign in',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const _FeatureRow(
                icon: Icons.check_circle_outline,
                iconColor: AppTheme.blue,
                text: 'Report issues in minutes',
              ),
              const SizedBox(height: 10),
              const _FeatureRow(
                icon: Icons.location_on_outlined,
                iconColor: AppTheme.green,
                text: 'Share exact locations',
              ),
              const SizedBox(height: 10),
              const _FeatureRow(
                icon: Icons.notifications_active_outlined,
                iconColor: AppTheme.orange,
                text: 'Receive updates on your reports',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.text,
            ),
          ),
        ),
      ],
    );
  }
}
