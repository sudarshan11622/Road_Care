import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:roadcare/app.dart';
import 'package:roadcare/models/report.dart';
import 'package:roadcare/state/app_state.dart';
import 'package:roadcare/Moria/admin/report_detail_screen.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _StubHttpClient();
  }
}

class _StubHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _StubHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(
    String method,
    Uri url, [
    Map<String, String>? headers,
  ]) async =>
      _StubHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _StubHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _StubHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable(const []).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  testWidgets('RoadCare app loads the welcome screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.textContaining('RoadCare'), findsWidgets);
    expect(find.text('Report a problem'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Already submitted a report? Sign in'), findsOneWidget);
  });

  testWidgets('uses a responsive layout on narrow mobile screens',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));

    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(LayoutBuilder), findsWidgets);
  });

  testWidgets('report flow offers camera and gallery photo options',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();

    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
  });

  testWidgets('requires a photo, category, and problem details',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();

    final continueButton = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
    await _addReportPhoto(tester);
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);
    await tester.tap(find.text('Pothole'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField).last, 'A deep pothole.');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(continueButton).onPressed, isNotNull);
  });

  testWidgets('citizen can open a report from the reports section',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'citizenLoggedIn': true,
      'phone': '9876543210',
    });
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pothole near Main Road'));
    await tester.pumpAndSettle();

    expect(find.text('RC-1048'), findsOneWidget);
    expect(find.text('Station Road, Ward 4'), findsOneWidget);
    expect(find.text('Large pothole causing difficulty for two-wheelers.'),
        findsOneWidget);
  });

  testWidgets('citizen can open a report from its notification',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'citizenLoggedIn': true,
      'phone': '9876543210',
      'notifications': jsonEncode([
        {
          'reportId': 'RC-1048',
          'phone': '9876543210',
          'title': 'Report resolved',
          'body': 'The problem you reported has been resolved.',
          'createdAt': DateTime(2026, 10, 7).toIso8601String(),
        },
      ]),
    });
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(
      tester
          .widgetList<Badge>(find.byType(Badge))
          .where((badge) => badge.isLabelVisible),
      hasLength(1),
    );
    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<Badge>(find.byType(Badge))
          .where((badge) => badge.isLabelVisible),
      isEmpty,
    );
    await tester.tap(find.text('Report resolved'));
    await tester.pumpAndSettle();

    expect(find.text('RC-1048'), findsOneWidget);
    expect(find.text('Station Road, Ward 4'), findsOneWidget);
    expect(find.text('Large pothole causing difficulty for two-wheelers.'),
        findsOneWidget);
  });

  testWidgets('admin can enter and save a rejection reason with keyboard open',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 640));
    final state = AppState();
    await state.load();
    addTearDown(state.dispose);
    addTearDown(() async {
      FocusManager.instance.primaryFocus?.unfocus();
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(const Size(390, 844));
    });

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(
          home: ReportDetailScreen(report: state.reports.first),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -480));
    await tester.pumpAndSettle();
    expect(find.text('Update status'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<ReportStatus>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rejected').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).last,
      'This report is outside the service area.',
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Save reason'));
    await tester.tap(find.text('Save reason'));
    await tester.pumpAndSettle();

    expect(
        find.text('This report is outside the service area.'), findsOneWidget);
    expect(state.reports.first.status, ReportStatus.rejected);
    expect(
      state.reports.first.rejectionReason,
      'This report is outside the service area.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone sign-in form scrolls above the on-screen keyboard',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      FocusManager.instance.primaryFocus?.unfocus();
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(const Size(390, 844));
    });

    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '9876543210');
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OTP screen scrolls above the on-screen keyboard',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 640));
    addTearDown(() async {
      FocusManager.instance.primaryFocus?.unfocus();
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(const Size(390, 844));
    });

    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign In').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '9876543210');
    await tester.ensureVisible(find.text('Next'));
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, '1234');
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Verify & continue'));
    await tester.pumpAndSettle();
    expect(find.text('Verify & continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a use my location action in the report flow',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await _advanceToLocationStep(tester);

    expect(find.text('Use my location'), findsOneWidget);
  });

  testWidgets('requires selecting an exact map location before confirmation',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await _advanceToLocationStep(tester);

    final confirmButton = find.widgetWithText(FilledButton, 'Confirm location');
    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);

    await _setReportCoordinates(tester);

    expect(tester.widget<FilledButton>(confirmButton).onPressed, isNotNull);
  });

  testWidgets('signed-in user lands on reports after submitting a report',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'citizenLoggedIn': true,
      'phone': '9876543210',
    });
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await _advanceToLocationStep(tester, category: 'Drainage');
    await _setReportCoordinates(tester);
    await tester.tap(find.text('Confirm location'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    expect(find.text('Track reports after login'), findsNothing);
    expect(find.text('Sign in'), findsNothing);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('My reports'), findsOneWidget);
    expect(find.text('Drainage reported'), findsOneWidget);
  });

  testWidgets('shows sign-in prompt after report for a signed-out citizen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await _advanceToLocationStep(tester, category: 'Drainage');
    await _setReportCoordinates(tester);
    await tester.tap(find.text('Confirm location'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    expect(find.text('Track reports after login'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('citizen can edit and persist their profile details',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'citizenLoggedIn': true,
      'phone': '9876543210',
    });
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Asha Patel');
    await tester.enterText(fields.at(1), 'asha@example.com');
    await tester.enterText(fields.at(2), '12 Main Road, Ward 4');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Asha Patel'), findsOneWidget);
    expect(find.text('asha@example.com'), findsOneWidget);
    expect(find.text('12 Main Road, Ward 4'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('citizenName_9876543210'), 'Asha Patel');
    expect(
      preferences.getString('citizenEmail_9876543210'),
      'asha@example.com',
    );
    expect(
      preferences.getString('citizenAddress_9876543210'),
      '12 Main Road, Ward 4',
    );
  });

  testWidgets('profile hides location access and admin settings has dark mode',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'citizenLoggedIn': true,
      'phone': '9876543210',
    });
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Location access'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    SharedPreferences.setMockInitialValues({'adminLoggedIn': true});
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsOneWidget);
    final darkModeSwitch = find.byType(Switch);
    expect(tester.widget<Switch>(darkModeSwitch).value, isFalse);
    await tester.tap(darkModeSwitch);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(darkModeSwitch).value, isTrue);
  });

  test('marks reports as trackable or non-trackable based on logged-in status',
      () {
    final trackable = Report(
      id: 'RC-2001',
      title: 'Trackable report',
      type: 'Pothole',
      location: 'Ward 1',
      description: 'Logged-in report',
      createdAt: DateTime.now(),
      status: ReportStatus.submitted,
      citizenName: 'User',
      citizenPhone: '9999999999',
      isTrackable: true,
    );

    final nonTrackable = Report(
      id: 'RC-2002',
      title: 'Anonymous report',
      type: 'Street light',
      location: 'Ward 2',
      description: 'Anonymous complaint',
      createdAt: DateTime.now(),
      status: ReportStatus.submitted,
      citizenName: 'Anonymous',
      isTrackable: false,
    );

    expect(trackable.isTrackable, isTrue);
    expect(nonTrackable.isTrackable, isFalse);
  });
}

const _imagePickerChannel = MethodChannel('plugins.flutter.io/image_picker');

Future<void> _addReportPhoto(WidgetTester tester) async {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(
    _imagePickerChannel,
    (call) async => '${Directory.current.path}\\assets\\images\\demo_road.jpg',
  );
  addTearDown(() => messenger.setMockMethodCallHandler(
        _imagePickerChannel,
        null,
      ));
  await tester.tap(find.text('Gallery'));
  await tester.pumpAndSettle();
}

Future<void> _advanceToLocationStep(
  WidgetTester tester, {
  String category = 'Pothole',
}) async {
  await _addReportPhoto(tester);
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(category));
  await tester.enterText(find.byType(TextField).last, 'A road hazard.');
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

Future<void> _setReportCoordinates(WidgetTester tester) async {
  await tester.enterText(
    find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Coordinates (latitude, longitude)',
    ),
    '12.34567, 76.54321',
  );
  await tester.tap(find.byTooltip('Set coordinates'));
  await tester.pumpAndSettle();
}
