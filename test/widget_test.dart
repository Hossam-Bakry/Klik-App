import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:klik_app/core/di/injector.dart';
import 'package:klik_app/main.dart';
import 'package:klik_app/modules/splash/presentation/pages/splash_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await sl.reset();
    // In-memory SharedPreferences for the onboarding flag read at startup.
    SharedPreferences.setMockInitialValues({});
    // flutter_secure_storage has no plugin in the test VM, so stub its channel
    // — the auth bootstrap reads the token and should just get null here.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
    await configureDependencies();
  });

  tearDown(() async => sl.reset());

  testWidgets('Splash shows for the startup delay, then resolves',
      (WidgetTester tester) async {
    // Render at a realistic phone size (≈393×852 logical) so the onboarding
    // layout the guard navigates to has room and doesn't overflow the default
    // 800×600 test window.
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const KlikApp());
    // Let the async JSON localization load resolve (Localizations renders an
    // empty frame until its delegates finish). pump(zero) doesn't advance the
    // 2s startup timer.
    await tester.pump();

    // Splash is shown during the startup delay (states still unknown).
    expect(find.byType(SplashView), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Still on splash before the 2s delay elapses.
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SplashView), findsOneWidget);

    // After the delay, the bootstrap fires and the guard navigates away.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(SplashView), findsNothing);
  });
}
