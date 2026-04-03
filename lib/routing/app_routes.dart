import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/view/new_screens/auth/login_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/auth/sign_up_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/auth/varification_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/auth/welcome_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/explore_cource/explore_course_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/main_screens/main_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/main_screens/profile.dart';
import 'package:new_graket_acadimy/view/new_screens/onboarding/onboard_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/other/courses_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/other/notifications_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/payment/congratulation_payment.dart';
import 'package:new_graket_acadimy/view/new_screens/payment/payment_way_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/payment/varify_payment_screen.dart';

import '../view/new_screens/main_screens/my_course_screen.dart';
import '../view/new_screens/other/enter_code_screen.dart';

Map<String, Widget Function(BuildContext)> routes = {
  /// new app
  AppRoutesNames.initialRoute: (context) => OnboardScreen(),
  AppRoutesNames.welcomeScreen: (context) => const WelcomeScreen(),
  AppRoutesNames.loginScreen: (context) => LoginScreen(),
  AppRoutesNames.signUpScreen: (context) => SignUpScreen(),
  AppRoutesNames.signUpVerification: (context) => VarificationScreen(),
  AppRoutesNames.mainScreen: (context) => HomeMainScreen(),
  AppRoutesNames.notificationsScreen: (context) => NotificationsScreen(),
  AppRoutesNames.coursesScreen: (context) => CoursesScreen(),
  // old app start
  AppRoutesNames.profileScreen: (context) => Profile(),
  AppRoutesNames.paymentWayScreen: (context) => PaymentWayScreen(),
  AppRoutesNames.varifyPaymentScreen: (context) => VarifyPaymentScreen(),
  AppRoutesNames.paymentSuccessScreen: (context) =>
      CongratulationPayment(), // Placeholder for actual success screen
  AppRoutesNames.exploreCourseScreen: (context) => ExploreCourseScreen(),
  AppRoutesNames.enterCodeScreen: (context) => EnterCodeScreen(),
  AppRoutesNames.myCoursesScreen: (context) => HomeMainScreen(routeInitialIndex: 0,),
};

class AppRoutesNames {
  // old app start
  static const String oldAppStart = "/splash";

  /// new app
  static const String initialRoute = "/";
  static const String onboardScreen = "/onboardScreen";
  static const String welcomeScreen = "/welcomeScreen";
  static const String loginScreen = "/LoginScreen";
  static const String signUpScreen = "/signUpScreen";
  static const String signUpVerification = "/verificationScreen";
  static const String mainScreen = "/mainScreen";
  static const String notificationsScreen = "/NotificationsScreen";
  static const String forYouScreen = "/ForYouScreen";
  static const String coursesScreen = "/coursesScreen";
  static const String profileScreen = "/ProfileScreen";
  static const String paymentWayScreen = "/PaymentWayScreen";
  static const String varifyPaymentScreen = "/VarifyPaymentScreen";
  static const String paymentSuccessScreen = "/PaymentSuccessScreen";
  static const String exploreCourseScreen = "/ExploreCourseScreen";
  static const String enterCodeScreen = "/EnterCodeScreen";
  static const String myCoursesScreen = "/MyCoursesScreen";
}
