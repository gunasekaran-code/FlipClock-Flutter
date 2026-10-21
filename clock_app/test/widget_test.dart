// Smoke test: the app boots to its loading splash and then, once
// preferences finish loading from local storage, shows the full-screen
// clock with no crashes.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clock_app/app.dart';
import 'package:clock_app/widgets/stored_image.dart';

void main() {
  testWidgets('Flip & Focus boots and loads the clock screen', (tester) async {
    // No persisted preferences yet — same as a fresh install.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FlipFocusApp());

    // First frame: settings are still loading, splash indicator is shown.
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

    // Let SharedPreferences + font registration resolve. Avoid
    // pumpAndSettle: the clock screen runs its own once-a-second Timer,
    // which would never let the test tree "settle".
    for (var i = 0;
        i < 20 && find.byType(CupertinoActivityIndicator).evaluate().isNotEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Splash is gone and the clock is visible.
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings screen opens without error', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const FlipFocusApp());
    for (var i = 0;
        i < 20 && find.byType(CupertinoActivityIndicator).evaluate().isNotEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    // Reveal the floating controls (hidden until the screen is tapped).
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byIcon(CupertinoIcons.settings));
    // Let the MaterialPageRoute push transition finish.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Every settings section (color/segmented pickers included) must build
    // without throwing — this is what would have caught a segmented
    // control whose default value wasn't one of its own options.
    expect(tester.takeException(), isNull);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('StoredImage renders a base64 data: URI (the web storage path)',
      (tester) async {
    // A valid 1x1 red PNG, base64-encoded — stands in for what
    // ImageService/FontService embed when running on web (no filesystem).
    const dataUri = 'data:image/png;base64,'
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(width: 40, height: 40, child: StoredImage(source: dataUri)),
      ),
    );
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
