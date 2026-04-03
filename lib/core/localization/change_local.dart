//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../services/services.dart';
//
//
// class LocalController extends GetxController {
//
// Locale?  language ;
// MyServices services = Get.find();
//    ThemeData appTheme = englishTheme;
//
// changeLanguage(String langCode)async{
//   Locale locale = Locale(langCode);
//   await services.sharedPreferences.setString("lang", langCode);
//  appTheme =  langCode == "ar" ? arabicTheme : englishTheme ;
//   Get.changeTheme(appTheme);
//   Get.updateLocale(locale);
// }
//
//
// @override
//   void onInit() {
//   requestPermission();
//   fcmConfig();
//   String? sharedPrefLang =  services.sharedPreferences.getString("lang");
//   if (sharedPrefLang == "ar"){
//     language = const Locale("ar");
//     appTheme = arabicTheme ;
//   }else if (sharedPrefLang =="en"){
//     language = const Locale("en");
//     appTheme = englishTheme ;
//   }else{
//     language = Locale(Get.deviceLocale!.languageCode);
//     appTheme = englishTheme ;
//   }
//   super.onInit();
//   }
// }