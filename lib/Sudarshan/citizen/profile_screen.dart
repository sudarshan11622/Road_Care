import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../app.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editProfile(BuildContext context, AppState state) async {
    final formKey = GlobalKey<FormState>();
    var name = state.citizenName;
    var email = state.citizenEmail;
    var address = state.citizenAddress;
    var profileImage = state.citizenProfileImage;
    var removeProfileImage = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit profile'),
          scrollable: true,
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProfileAvatar(
                    imageData: profileImage,
                    radius: 42,
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 75,
                        maxWidth: 512,
                        maxHeight: 512,
                      );
                      if (picked == null) return;
                      final bytes = await picked.readAsBytes();
                      if (!context.mounted) return;
                      setDialogState(() {
                        profileImage = base64Encode(bytes);
                        removeProfileImage = false;
                      });
                    },
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Change profile photo'),
                  ),
                  if (profileImage != null)
                    TextButton(
                      onPressed: () => setDialogState(() {
                        profileImage = null;
                        removeProfileImage = true;
                      }),
                      child: const Text('Remove photo'),
                    ),
                  TextFormField(
                    initialValue: name,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (value) => name = value,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => email = value,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isNotEmpty &&
                          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(trimmed)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: address,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (value) => address = value,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  if (state.phone.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: '+91 ${state.phone}',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        helperText: 'Used to sign in and identify your reports',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await state.updateCitizenProfile(
                  name: name,
                  email: email,
                  address: address,
                  profileImage: profileImage,
                  removeProfileImage: removeProfileImage,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => SafeArea(
        child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
        children: [
          const Text('Profile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('Manage your RoadCare account.',
              style: TextStyle(color: AppTheme.muted)),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: _ProfileAvatar(
                imageData: state.citizenProfileImage,
                radius: 24,
              ),
              title: Text(state.citizenName,
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(state.phone.isEmpty
                  ? 'Citizen account'
                  : '+91 ${state.phone}'),
              trailing: IconButton(
                tooltip: 'Edit profile',
                onPressed: () => _editProfile(context, state),
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
          ),
          if (state.citizenEmail.isNotEmpty || state.citizenAddress.isNotEmpty)
            Card(
              child: Column(
                children: [
                  if (state.citizenEmail.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(state.citizenEmail),
                    ),
                  if (state.citizenAddress.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Address'),
                      subtitle: Text(state.citizenAddress),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Personal information'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _editProfile(context, state),
                ),
                const ListTile(
                  leading: Icon(Icons.notifications_none),
                  title: Text('Notifications'),
                  trailing: Switch(value: true, onChanged: null),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  trailing: Switch(
                    value: state.isDarkMode,
                    onChanged: (value) async {
                      await state.setDarkMode(value);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.red),
                  title: const Text('Log out',
                      style: TextStyle(color: AppTheme.red)),
                  onTap: () async {
                    await state.logoutCitizen();
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
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageData, required this.radius});

  final String? imageData;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    if (imageData != null) {
      try {
        bytes = base64Decode(imageData!);
      } on FormatException {
        bytes = null;
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.blue,
      foregroundImage: bytes == null ? null : MemoryImage(bytes),
      child: bytes == null
          ? Icon(Icons.person, color: Colors.white, size: radius)
          : null,
    );
  }
}
