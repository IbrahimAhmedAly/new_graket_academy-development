import 'dart:developer';
import 'dart:io';

import 'package:screen_protector/screen_protector.dart';

import '../constants/security_flags.dart';

/// Enables protections against screenshots and screen recordings.
Future<void> enableScreenSecurity() async {
  try {
    if (!kEnableScreenSecurity) {
      await disableScreenSecurity();
      return;
    }
    await ScreenProtector.preventScreenshotOn();
    if (Platform.isAndroid) {
      await ScreenProtector.protectDataLeakageOn();
    }
  } catch (error, stackTrace) {
    log(
      'Failed to enable screen security: $error',
      name: 'ScreenSecurity',
      stackTrace: stackTrace,
    );
  }
}

/// Disables protections against screenshots and screen recordings.
Future<void> disableScreenSecurity() async {
  try {
    await ScreenProtector.preventScreenshotOff();
    if (Platform.isAndroid) {
      await ScreenProtector.protectDataLeakageOff();
    }
  } catch (error, stackTrace) {
    log(
      'Failed to disable screen security: $error',
      name: 'ScreenSecurity',
      stackTrace: stackTrace,
    );
  }
}
