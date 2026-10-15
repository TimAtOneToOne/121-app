import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_twenty_one/main.dart';
import 'package:one_twenty_one/wellness/screens.dart';
import 'package:one_twenty_one/wellness/state.dart';

void main() {
  setUpAll(() async {
    for (final font in [
      ('Instrument Sans', 'InstrumentSans.ttf'),
      ('Family', 'Family-Light.ttf'),
    ]) {
      final loader = FontLoader(font.$1)
        ..addFont(rootBundle.load('assets/fonts/${font.$2}'));
      await loader.load();
    }
  });
  Future<void> openScreen(
    WidgetTester tester,
    WellnessPage page, {
    WellnessState? state,
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 978);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Instrument Sans',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 14, height: 1.2, letterSpacing: 0),
          ),
        ),
        home: WellnessScreen(state: state ?? WellnessState(), page: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final page in screenNodes.keys) {
    testWidgets('${page.name} renders at phone widths', (tester) async {
      for (final width in [390.0, 320.0]) {
        await tester.pumpWidget(const SizedBox());
        await openScreen(tester, page, width: width);
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.name} at $width',
        );
      }
    });
  }

  testWidgets('profile filters properties and validates names', (tester) async {
    final state = WellnessState();
    await openScreen(tester, WellnessPage.profile, state: state);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '');
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your first name'), findsOneWidget);
    await tester.enterText(fields.first, 'Taylor');
    await tester.enterText(find.byType(TextField).last, 'Scottsdale');
    await tester.pumpAndSettle();
    expect(find.text('Caesars Republic Scottsdale'), findsOneWidget);
    expect(find.text('Harrah’s Northern California'), findsNothing);
    await tester.tap(find.text('Caesars Republic Scottsdale'));
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Taylor Endsley'), findsOneWidget);
    expect(state.propertyIndex, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manual log validates input and updates progress', (
    tester,
  ) async {
    final state = WellnessState()..currentChallenge = 'Hydration Habit';
    await openScreen(tester, WellnessPage.log, state: state);
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.tap(find.text('Save log'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a number greater than zero'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '8500');
    await tester.tap(find.text('Save log'));
    await tester.pumpAndSettle();
    expect(state.points, 10);
    expect(find.text('Steps: 8500'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('document removal disables submission', (tester) async {
    await openScreen(tester, WellnessPage.document);
    await tester.tap(find.byTooltip('Remove document'));
    await tester.pumpAndSettle();
    expect(find.text('spring-5k-receipt.pdf'), findsNothing);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Submit for review'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets(
    'permission switches require consent and denial does not connect',
    (tester) async {
      final state = WellnessState()..demoConnections.clear();
      await openScreen(tester, WellnessPage.applePermission, state: state);
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Allow'))
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Don’t Allow'));
      await tester.pumpAndSettle();
      expect(state.demoConnections, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  test('daily activity and module credits cannot be collected twice', () {
    final state = WellnessState()..currentChallenge = 'Test challenge';
    state.logActivity('Steps', 5000, DateTime(2026, 10, 14), '');
    state.logActivity('Steps', 6000, DateTime(2026, 10, 14), '');
    expect(state.points, 10);
    expect(state.completeModule(), isTrue);
    expect(state.completeModule(), isFalse);
    expect(state.points, 35);
    state.submit('receipt.pdf', '5K race entry', 50);
    expect(state.points, 35);
    expect(state.activities.first.pending, isTrue);
  });

  testWidgets('home opens onboarding and health navigation', (tester) async {
    tester.view.physicalSize = const Size(390, 919);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const CareApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Join Challenge'));
    await tester.pumpAndSettle();
    expect(find.text('Steps Showdown'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
