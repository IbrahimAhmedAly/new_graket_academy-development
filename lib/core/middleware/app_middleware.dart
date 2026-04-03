import 'package:get/get.dart';
import 'package:flutter/material.dart';


import '../../routing/app_routes.dart';
import '../constants/app_strings.dart';
import '../services/services.dart';

class AppMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  MyServices myServices = Get.find();

  @override
  RouteSettings? redirect(String? route) {
    bool? firstTime = myServices.sharedPreferences.getBool(AppSharedPrefKeys.firstTimeKey);
    bool? savedLogin = myServices.sharedPreferences.getBool(AppSharedPrefKeys.savedLoginKey);
    final token = myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
        myServices.sharedPreferences.getString('token');
    final hasToken = token != null && token.isNotEmpty;
    if (firstTime == false) {
      if(savedLogin == true && hasToken){
        return const RouteSettings(name: AppRoutesNames.mainScreen );
      }else{
        return const RouteSettings(name: AppRoutesNames.loginScreen);
      }
    }else{
      return null;
    }
  }
}
