import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_twenty_one/main.dart';

void main() {
  Future<void> openApp(
    WidgetTester tester, {
    Size size = const Size(390, 919),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const CareApp());
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard fits the design viewport and narrow phones', (
    tester,
  ) async {
    for (final width in [390.0, 320.0]) {
      await openApp(tester, size: Size(width, 919));
      expect(find.text('Good afternoon, PJ'), findsOneWidget);
      expect(find.text('Routine care'), findsOneWidget);
      expect(find.text('Request Labs'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('composer rejects whitespace and keeps a local message', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Start a conversation'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton &&
                  widget.tooltip == 'Save message locally',
            ),
          )
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byType(TextField),
      'I would like to schedule a visit.',
    );
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();
    expect(find.text('I would like to schedule a visit.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a conversation'));
    await tester.pumpAndSettle();
    expect(find.text('I would like to schedule a visit.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('visit date opens a request without booking an appointment', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Schedule a Visit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Visit request ·'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('messages stay in their own conversation', (tester) async {
    await openApp(tester);
    await tester.tap(find.text('Start a conversation'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A new concern');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calf pain after travel'));
    await tester.pumpAndSettle();
    expect(find.text('A new concern'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text remains scrollable without overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openApp(tester, size: const Size(320, 700));
    await tester.scrollUntilVisible(find.text('Calf pain after travel'), 200);
    expect(find.text('Calf pain after travel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
