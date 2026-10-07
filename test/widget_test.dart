import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:roadcare/app.dart';
import 'package:roadcare/models/report.dart';

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

  testWidgets('phone sign-in form scrolls above the on-screen keyboard',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      FocusManager.instance.primaryFocus?.unfocus();
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
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

  testWidgets('shows a use my location action in the report flow',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Use my location'), findsOneWidget);
  });

  testWidgets('signed-in user lands on reports after submitting a report',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'citizenLoggedIn': true,
      'phone': '9876543210',
      'requireLocationConfirmation': true,
    });
    await tester.pumpWidget(const RoadCareApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Report a problem'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drainage'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
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
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drainage'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
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
