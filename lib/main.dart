import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:new_graket_acadimy/routing/app_routes.dart';

import 'core/constants/security_flags.dart';
import 'core/functions/check_emulator.dart';
import 'core/localization/translation.dart';
import 'core/services/services.dart';
import 'get_screens.dart';
import 'injection.dart';

//hello ahmed youssef we start here
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final shouldBlockEmulator = kReleaseMode && kBlockEmulatorsInRelease;
  if (shouldBlockEmulator && await checkIfEmulator()) {
    runApp(const EmulatorNotSupportedApp());
    return;
  }
  final services = Get.find<MyServices>();
  final savedLangCode = services.sharedPreferences.getString('lang');
  final deviceLocale = Get.deviceLocale;
  final locale = savedLangCode != null
      ? Locale(savedLangCode)
      : (deviceLocale ?? const Locale('ar'));
  runApp(MyApp(initialLocale: locale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Graket academy',
          debugShowCheckedModeBanner: false,
          getPages: getScreens,
          initialBinding: AppBinding(),
          translations: MyTranslation(),
          locale: initialLocale,
          fallbackLocale: const Locale('ar'),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            useMaterial3: true,
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.transparent,
            ),
            fontFamily: 'Arb',
            scaffoldBackgroundColor: Colors.grey.shade100,
          ),
          // routes: routes,
          initialRoute: AppRoutesNames.initialRoute,
        );
      },
    );
  }
}

/// used when used emulator not supported
class EmulatorNotSupportedApp extends StatelessWidget {
  const EmulatorNotSupportedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graket academy',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Unsupported Device')),
        body: const Center(child: Text('This app does not support emulators.')),
      ),
    );
  }
}

/// app test account
///  email :  mobtester@gmail.com
///  pW : 123456
