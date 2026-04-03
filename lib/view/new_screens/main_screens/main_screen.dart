import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/home_controller/home_controller.dart';
import 'package:new_graket_acadimy/controller/basket_controller.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/services/screen_security.dart';
import 'package:new_graket_acadimy/view/new_screens/main_screens/basket_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/main_screens/home_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/main_screens/my_course_screen.dart';
import 'package:new_graket_acadimy/view/new_screens/main_screens/profile.dart'
    show Profile;
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/custom_navigation_bar/MotionTabBar.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/custom_navigation_bar/MotionTabBarController.dart';

class HomeMainScreen extends StatefulWidget {
 final int? routeInitialIndex;
  const HomeMainScreen({super.key, this.routeInitialIndex});

  @override
  _HomeMainScreenState createState() => _HomeMainScreenState();

}

class _HomeMainScreenState extends State<HomeMainScreen> with TickerProviderStateMixin {
  // TabController? _tabController;
  MotionTabBarController? _motionTabBarController;
  String _currentSelectedTab = "Home";
  @override
  void initState() {
    super.initState();
    enableScreenSecurity();

    _motionTabBarController = MotionTabBarController(
      initialIndex: widget.routeInitialIndex ?? 2,
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _motionTabBarController!.dispose();
  }



  @override
  Widget build(BuildContext context) {
    // Default selected tab
    final int? data = widget.routeInitialIndex ?? ModalRoute
        .of(context)!
        .settings
        .arguments as int?;
    if (data != null) {
      // _motionTabBarController!.index =
      //     data; // Set the initial index if provided
      _currentSelectedTab = data == 0
          ? "My Courses"
          : data == 1
          ? "Basket"
          : data == 2
          ? "Home"
          : "Profile";
    }
    return GetBuilder<HomeController>(
      assignId: true,
      builder: (controller) {
        return GetBuilder<BasketController>(
          init: Get.isRegistered<BasketController>()
              ? Get.find<BasketController>()
              : BasketController(),
          builder: (basketController) {
            final badge = _buildBasketBadge(basketController.basketCount);
            return Scaffold(
              backgroundColor: Colors.white,
              extendBody: true,
              extendBodyBehindAppBar: true,
              bottomNavigationBar: MotionTabBar(
                controller: _motionTabBarController,
                initialSelectedTab: _currentSelectedTab,
                useSafeArea: true,
                labels: const ["My Courses", "Basket", "Home", "Profile"],
                icons: const [
                  Icons.cases_outlined,
                  Icons.shopping_basket_outlined,
                  Icons.home,
                  Icons.person_outline,
                ],
                badges: [null, badge, null, null],
                tabSize: 60,
                tabBarHeight: 55,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColor.mainScreenButtons,
                  fontWeight: FontWeight.bold,
                ),
                tabIconColor: AppColor.mainScreenButtons,
                tabIconSize: 25.0,
                tabIconSelectedSize: 50.0,
                tabSelectedColor: AppColor.mainScreenButtons,
                tabIconSelectedColor: Colors.white,
                tabBarColor: Colors.white,
                onTabItemSelected: (int value) {
                  setState(() {
                    _motionTabBarController!.index = value;
                  });
                },
              ),
              body: Container(
                alignment: Alignment.topCenter,
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(
                        AssetsPath.mainScreen,
                      )),
                ),
                child: Container(
                  child: buildTabContent(_motionTabBarController!.index),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget? _buildBasketBadge(int count) {
    if (count <= 0) return null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? "99+" : "$count",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Widget buildTabContent(int index) {
  switch (index) {
    case 0:
      return MyCourseScreen();
    case 1:
      return BasketScreen();
    case 2:
      return HomeScreen();
    case 3:
      return Profile();
    default:
      return Center(child: Text("Unknown Tab"));
  }
}
