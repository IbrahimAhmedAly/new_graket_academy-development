
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyServices extends GetxService {
  late SharedPreferences sharedPreferences;

  Future<MyServices> init() async {
    // await Firebase.initializeApp(
    //   options: Platform.isIOS
    //       ? const FirebaseOptions(
    //       apiKey: "--",
    //       appId: "1:::",
    //       messagingSenderId: "",
    //       projectId: "-")
    //       : const FirebaseOptions(
    //       apiKey: "",
    //       appId: "1:::",
    //       messagingSenderId: "",
    //       projectId: ""
    //   ),
    // );
    // FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    //
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    //   return true;
    // };
    sharedPreferences = await SharedPreferences.getInstance();
    return this;
  }
}

Future<void> initialServices() async {
  await Get.putAsync(() => MyServices().init());
}
