import 'package:get/get.dart';

import 'controller/courses/code_controller_impl.dart';
import 'controller/auth_controller/login_controller.dart';
import 'controller/auth_controller/signup_controller.dart';
import 'controller/auth_controller/signup_varification_controller.dart';
import 'controller/basket_controller.dart';
import 'controller/home_controller/course_details_controller.dart';
import 'controller/home_controller/courses_controller.dart';
import 'controller/home_controller/home_controller.dart';
import 'controller/my_courses_controller.dart';
import 'controller/notifications_controller.dart';
import 'controller/profile_controller.dart';
import 'core/class/data_request.dart';

class AppBinding extends Bindings {
  @override
  void dependencies()  {

 Get.lazyPut(() => LoginControllerImpl(),fenix: true);
 Get.lazyPut(() => SignUpControllerImpl(),fenix: true);
 Get.lazyPut(() => SignupVarificationControllerImpl(),fenix: true);
 Get.lazyPut(() => HomeController(),fenix: true);
 Get.lazyPut(() => CoursesControllerImp(),fenix: true);
 Get.lazyPut(() => CourseDetailsControllerImp(),fenix: true);
 Get.lazyPut(() => CodeControllerImpl(),fenix: true);
 Get.lazyPut(() => BasketController(),fenix: true);
 Get.lazyPut(() => MyCoursesController(),fenix: true);
 Get.lazyPut(() => NotificationsController(),fenix: true);
 Get.lazyPut(() => ProfileController(),fenix: true);


    Get.put(DataRequest());

  }

}
