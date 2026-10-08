import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/common/widgets/screen_capture_shield.dart';
import 'package:new_graket_acadimy/core/localization/translation.dart';
import 'package:new_graket_acadimy/core/services/screen_protection_service.dart';

void main() {
  late ScreenProtectionService protection;
  late int taps;

  setUp(() {
    // Registered without init(): the shield only reads isCaptured.
    protection = Get.put(ScreenProtectionService());
    taps = 0;
  });

  tearDown(Get.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    // A 360×640 phone, as the app's ScreenUtil design size expects; the
    // default test window would scale its text up past the screen.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 640),
        minTextAdapt: true,
        builder: (context, child) => GetMaterialApp(
          translations: MyTranslation(),
          locale: const Locale('en'),
          builder: (context, child) => ScreenCaptureShield(child: child!),
          home: Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => taps++,
                child: const Text('Lesson'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the app while the screen is not captured', (tester) async {
    await pumpApp(tester);

    expect(find.text("Screen recording isn't allowed"), findsNothing);
    await tester.tap(find.text('Lesson'));
    expect(taps, 1);
  });

  testWidgets('covers the app and blocks taps during a capture', (
    tester,
  ) async {
    await pumpApp(tester);

    protection.isCaptured.value = true;
    await tester.pump();

    expect(find.text("Screen recording isn't allowed"), findsOneWidget);
    await tester.tap(find.text('Lesson'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('gives the app back, as it was, when the capture stops', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Lesson'));

    protection.isCaptured.value = true;
    await tester.pump();
    protection.isCaptured.value = false;
    await tester.pump();

    expect(find.text("Screen recording isn't allowed"), findsNothing);
    await tester.tap(find.text('Lesson'));
    expect(taps, 2);
  });
}
