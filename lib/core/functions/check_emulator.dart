import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

Future<bool> checkIfEmulator() async {
  try {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.isPhysicalDevice == false) {
        return true;
      }
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (iosInfo.isPhysicalDevice == false) {
        return true;
      }
    }
  } catch (error, stackTrace) {
    log(
      'Emulator check failed: $error',
      name: 'EmulatorCheck',
      stackTrace: stackTrace,
    );
  }

  return false;
}
