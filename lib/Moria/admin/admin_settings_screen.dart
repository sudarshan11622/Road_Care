import 'package:flutter/material.dart';
import '../../app.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _organizationController;
  late final TextEditingController _serviceAreaController;
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final state = AppScope.of(context);
    _organizationController = TextEditingController(
      text: state.organizationName,
    );
    _serviceAreaController = TextEditingController(text: state.serviceArea);
    _initialized = true;
  }

  @override
  void dispose() {
    _organizationController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  Future<void> _save(AppState state) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await state.saveAdminSettings(
      organizationName: _organizationController.text,
      serviceArea: _serviceAreaController.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Administration settings saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
        children: [
          const Text('Administration settings',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('Configure RoadCare operations.',
              style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Organization details',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _organizationController,
                          decoration: const InputDecoration(
                            labelText: 'Organization name',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter an organization name'
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _serviceAreaController,
                          decoration: const InputDecoration(
                            labelText: 'Default service area',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter a service area'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: _saving ? 'Saving...' : 'Save changes',
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            try {
                              await _save(state);
                            } finally {
                              if (mounted) setState(() => _saving = false);
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  trailing: Switch(
                    value: state.isDarkMode,
                    onChanged: state.setDarkMode,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.red),
                  title: const Text('Sign out',
                      style: TextStyle(color: AppTheme.red)),
                  onTap: () async {
                    await state.logoutAdmin();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/welcome', (_) => false);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
