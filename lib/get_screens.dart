import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/view/new_screens/auth/login_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/auth/sign_up_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/auth/varification_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/auth/welcome_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/course_player/course_player_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/explore_cource/explore_course_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/main_screens/home_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/main_screens/main_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/onboarding/onboard_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/other/courses_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/other/enter_code_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/other/notifications_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/quiz/quiz_screen.dart';

import 'core/middleware/app_middleware.dart';

List<GetPage<dynamic>> getScreens = [
  GetPage(
      name: '/',
      page: () => const OnboardScreen(),
      middlewares: [AppMiddleware()]),
  GetPage(
      name: AppRoutesNames.loginScreen,
      page: () => const LoginScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 700)),
  GetPage(
      name: AppRoutesNames.signUpScreen,
      page: () => SignUpScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 700)),
  GetPage(
      name: AppRoutesNames.welcomeScreen,
      page: () => WelcomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300)),
  GetPage(
      name: AppRoutesNames.signUpVerification,
      page: () => VarificationScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700)),
  GetPage(
      name: AppRoutesNames.mainScreen,
      page: () => HomeMainScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700)),
  GetPage(
      name: AppRoutesNames.coursesScreen,
      page: () => CoursesScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700)),
  GetPage(
      name: AppRoutesNames.exploreCourseScreen,
      page: () => ExploreCourseScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700)),
  GetPage(
      name: AppRoutesNames.enterCodeScreen,
      page: () => EnterCodeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700)),
  GetPage(
      name: AppRoutesNames.myCoursesScreen,
      page: () => HomeMainScreen(routeInitialIndex: 0),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700)),
  GetPage(
      name: AppRoutesNames.notificationsScreen,
      page: () => const NotificationsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300)),
  GetPage(
      name: AppRoutesNames.coursePlayerScreen,
      page: () => const CoursePlayerScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400)),
  GetPage(
      name: AppRoutesNames.quizScreen,
      page: () => const QuizScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350)),
];
