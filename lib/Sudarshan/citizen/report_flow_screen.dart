import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../app.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/report_image.dart';

class ReportFlowScreen extends StatefulWidget {
  const ReportFlowScreen({super.key});

  @override
  State<ReportFlowScreen> createState() => _ReportFlowScreenState();
}

class _ReportFlowScreenState extends State<ReportFlowScreen> {
  int step = 0;
  String? imagePath;
  String problem = 'Pothole';
  String location = '';
  String trackingPhone = '';
  final description = TextEditingController();

  final problems = const [
    ('Pothole', Icons.circle_outlined),
    ('Street light', Icons.lightbulb_outline),
    ('Drainage', Icons.water_drop_outlined),
    ('Road damage', Icons.construction_outlined),
    ('Traffic sign', Icons.signpost_outlined),
    ('Other', Icons.more_horiz),
  ];

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  Future<void> pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked == null) return;
    setState(() => imagePath = picked.path);
  }

  Future<void> next() async {
    if (step < 3) {
      setState(() => step++);
      return;
    }
    final state = AppScope.of(context);
    await state.addReport(
      title:
          problem == 'Pothole' ? 'Pothole near Main Road' : '$problem reported',
      type: problem,
      location: location,
      description: description.text.trim().isEmpty
          ? 'Reported through RoadCare.'
          : description.text.trim(),
      imagePath: imagePath,
      phoneNumber: trackingPhone.trim().isEmpty ? null : trackingPhone,
    );
    if (!mounted) return;
    setState(() => step = 4);
  }

  @override
  Widget build(BuildContext context) {
    if (step == 4) return const _SuccessScreen();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          if (step == 0) {
            Navigator.pop(context);
          } else {
            setState(() => step--);
          }
        }),
        title: const Text('Report a problem'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(
              value: (step + 1) / 4,
              minHeight: 4,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _buildStep(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (step) {
      case 0:
        return _PhotoStep(
          onPick: pickPhoto,
          onNext: next,
          imagePath: imagePath,
        );
      case 1:
        return _ProblemStep(
          selected: problem,
          problems: problems,
          onSelected: (v) => setState(() => problem = v),
          description: description,
          onNext: next,
        );
      case 2:
        return _LocationStep(
          location: location,
          onLocationChanged: (v) => setState(() => location = v),
          onNext: next,
        );
      default:
        return _ReviewStep(
          problem: problem,
          location: location,
          imagePath: imagePath,
          description: description.text,
          trackingPhone: trackingPhone,
          onTrackingPhoneChanged: (value) =>
              setState(() => trackingPhone = value),
          onSubmit: next,
        );
    }
  }
}

class _StepFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String button;
  final VoidCallback? onNext;

  const _StepFrame({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.button,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          const SizedBox(height: 7),
          Text(subtitle,
              style: const TextStyle(color: AppTheme.muted, height: 1.4)),
          const SizedBox(height: 20),
          Expanded(child: child),
          PrimaryButton(label: button, onPressed: onNext),
        ],
      ),
    );
  }
}

class _PhotoStep extends StatelessWidget {
  final ValueChanged<ImageSource> onPick;
  final VoidCallback onNext;
  final String? imagePath;

  const _PhotoStep({
    required this.onPick,
    required this.onNext,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      title: 'Add a photo',
      subtitle: 'A clear photo helps the road team understand the problem.',
      button: 'Continue',
      onNext: onNext,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: imagePath == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 34, color: AppTheme.blue),
                        SizedBox(height: 10),
                        Text('Add a photo of the problem'),
                        SizedBox(height: 3),
                        Text(
                          'Take a live picture or choose one from your gallery.',
                          style: TextStyle(color: AppTheme.muted, fontSize: 12),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: reportImage(
                        imagePath!,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => onPick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take photo'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onPick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
          if (imagePath == null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Photo is recommended, but not required.',
                style: TextStyle(fontSize: 12, color: AppTheme.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProblemStep extends StatelessWidget {
  final String selected;
  final List<(String, IconData)> problems;
  final ValueChanged<String> onSelected;
  final TextEditingController description;
  final VoidCallback onNext;

  const _ProblemStep({
    required this.selected,
    required this.problems,
    required this.onSelected,
    required this.description,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      title: 'What’s the problem?',
      subtitle: 'Choose the category that best describes the issue.',
      button: 'Continue',
      onNext: onNext,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: problems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.65,
              ),
              itemBuilder: (_, i) {
                final item = problems[i];
                final active = selected == item.$1;
                return InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => onSelected(item.$1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.blue.withValues(alpha: .07)
                          : Colors.white,
                      border: Border.all(
                        color: active ? AppTheme.blue : AppTheme.border,
                        width: active ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 13),
                        Icon(item.$2,
                            color: active ? AppTheme.blue : AppTheme.muted),
                        const SizedBox(width: 8),
                        Flexible(
                            child: Text(item.$1,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: description,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Additional details (optional)',
              hintText: 'Tell us what you noticed...',
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStep extends StatefulWidget {
  final String location;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onNext;

  const _LocationStep({
    required this.location,
    required this.onLocationChanged,
    required this.onNext,
  });

  @override
  State<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<_LocationStep> {
  late final MapController mapController;
  final TextEditingController _coordinatesController = TextEditingController();
  late LatLng selectedPosition;
  bool _hasSelectedLocation = false;

  static const indiaCenter = LatLng(22.3511, 78.6677);

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    selectedPosition = _parseLocation(widget.location) ?? indiaCenter;
    _hasSelectedLocation = _parseLocation(widget.location) != null;
    if (_hasSelectedLocation) {
      _coordinatesController.text =
          '${selectedPosition.latitude}, ${selectedPosition.longitude}';
    }
  }

  @override
  void dispose() {
    _coordinatesController.dispose();
    super.dispose();
  }

  LatLng? _parseLocation(String value) {
    final match =
        RegExp(r'[-]?\d+(?:\.\d+)?\s*,\s*[-]?\d+(?:\.\d+)?').firstMatch(value);
    if (match == null) return null;

    final parts = match.group(0)!.split(',');
    if (parts.length != 2) return null;

    try {
      return LatLng(
        double.parse(parts[0].trim()),
        double.parse(parts[1].trim()),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _useCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Location access is required to use your current location.'),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    if (!mounted) return;

    final point = LatLng(position.latitude, position.longitude);
    mapController.move(point, 14);
    _updateSelection(point);
  }

  void _updateSelection(LatLng point) {
    setState(() {
      selectedPosition = point;
      _hasSelectedLocation = true;
      _coordinatesController.text = '${point.latitude.toStringAsFixed(5)}, '
          '${point.longitude.toStringAsFixed(5)}';
    });
    widget.onLocationChanged(
      'Selected location: ${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
    );
  }

  void _selectEnteredCoordinates() {
    final parts = _coordinatesController.text.split(',');
    final latitude =
        parts.length == 2 ? double.tryParse(parts[0].trim()) : null;
    final longitude =
        parts.length == 2 ? double.tryParse(parts[1].trim()) : null;
    if (latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid coordinates as latitude, longitude.'),
        ),
      );
      return;
    }

    final point = LatLng(latitude, longitude);
    mapController.move(point, 14);
    _updateSelection(point);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      title: 'Confirm the location',
      subtitle: 'Select the exact place where the issue was noticed.',
      button: 'Confirm location',
      onNext: _hasSelectedLocation ? widget.onNext : null,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: selectedPosition,
                  initialZoom: 14,
                  minZoom: 9,
                  maxZoom: 18,
                  onTap: (_, point) => _updateSelection(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.roadcare',
                  ),
                  if (_hasSelectedLocation)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedPosition,
                          width: 42,
                          height: 42,
                          child: const Icon(
                            Icons.location_on,
                            color: AppTheme.blue,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.gps_fixed, color: AppTheme.blue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hasSelectedLocation
                        ? 'Lat ${selectedPosition.latitude.toStringAsFixed(5)}, '
                            'Lng ${selectedPosition.longitude.toStringAsFixed(5)}'
                        : 'Tap the map or use your location to select a point',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _coordinatesController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Coordinates (latitude, longitude)',
                    hintText: 'e.g. 12.34567, 76.54321',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _selectEnteredCoordinates(),
                ),
              ),
              IconButton(
                onPressed: _selectEnteredCoordinates,
                tooltip: 'Set coordinates',
                icon: const Icon(Icons.check_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _useCurrentLocation,
                  icon: const Icon(Icons.my_location_outlined),
                  label: const Text('Use my location'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    mapController.move(indiaCenter, 5);
                  },
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('India view'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final String problem;
  final String location;
  final String? imagePath;
  final String description;
  final String trackingPhone;
  final ValueChanged<String>? onTrackingPhoneChanged;
  final VoidCallback onSubmit;

  const _ReviewStep({
    required this.problem,
    required this.location,
    required this.imagePath,
    required this.description,
    required this.trackingPhone,
    this.onTrackingPhoneChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return _StepFrame(
      title: 'Review your report',
      subtitle: 'Check the details before sending the report.',
      button: 'Submit report',
      onNext: onSubmit,
      child: ListView(
        children: [
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: reportImage(
                imagePath!,
                width: double.infinity,
                height: 165,
              ),
            ),
          const SizedBox(height: 12),
          TextFormField(
            keyboardType: TextInputType.phone,
            maxLength: 10,
            initialValue: trackingPhone,
            onChanged: onTrackingPhoneChanged,
            decoration: const InputDecoration(
              labelText: 'Mobile number for tracking (optional)',
              hintText: 'Enter 10-digit number',
              prefixText: '+91 ',
            ),
          ),
          const SizedBox(height: 12),
          _ReviewTile(label: 'Problem', value: problem),
          _ReviewTile(label: 'Location', value: location),
          _ReviewTile(
            label: 'Details',
            value: description.isEmpty ? 'No additional details.' : description,
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 72,
              child: Text(label,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    void finish() {
      if (state.citizenLoggedIn) {
        state.setCitizenTab(1);
        Navigator.pushNamedAndRemoveUntil(context, '/citizen', (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFEFDD),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFF8ED4A5), width: 5),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF1E8E5A),
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'REPORT RC-1052',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.8,
                      color: AppTheme.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Report submitted',
                    style: TextStyle(
                      fontSize: 33,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Thanks for helping improve your neighborhood. The city team has received your report.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.muted,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Problem',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.muted,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Pothole',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.blue.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Submitted',
                            style: TextStyle(
                              color: AppTheme.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!state.citizenLoggedIn) ...[
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/phone'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_none_rounded,
                                color: AppTheme.blue),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Track reports after login',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Sign in',
                              style: TextStyle(
                                color: AppTheme.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: finish,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (!state.citizenLoggedIn) ...[
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: finish,
                      child: const Text(
                        'No thanks, I’m done',
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
