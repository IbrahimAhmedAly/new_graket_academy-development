import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import '../../core/services/services.dart';
import '../constants/app_strings.dart';

MyServices myServices = Get.find();
Future<String> getSerial() async {
  final cachedSerial =
      myServices.sharedPreferences.getString(AppSharedPrefKeys.deviceSerialKey);
  if (cachedSerial != null && cachedSerial.isNotEmpty) {
    return cachedSerial;
  }
  String serial = "";
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    serial =  androidInfo.id ;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    serial = iosInfo.identifierForVendor ?? "";
  }
  if (serial.isNotEmpty) {
    myServices.sharedPreferences
        .setString(AppSharedPrefKeys.deviceSerialKey, serial);
  }
  return serial;
}
