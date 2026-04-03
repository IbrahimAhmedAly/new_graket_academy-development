import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:new_graket_acadimy/controller/notifications_controller.dart';
import 'package:new_graket_acadimy/core/class/handling_view_data.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/enums/notification_type.dart';
import 'package:new_graket_acadimy/view/new_widgets/other_widgets/notified_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationsController>(
      init: Get.isRegistered<NotificationsController>()
          ? Get.find<NotificationsController>()
          : NotificationsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            forceMaterialTransparency: true,
            backgroundColor: Colors.transparent,
          ),
          body: HandlingViewData(
            requestStatus: controller.requestStatus,
            widget: Container(
              alignment: Alignment.bottomCenter,
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      AssetsPath.mainScreen,
                    )),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: AppPadding.pad60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: AppPadding.pad20),
                      child: Container(
                        width: AppWidth.w335,
                        alignment: Alignment.topLeft,
                        child: Text(
                          AppStrings.notifications,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize32,
                            fontWeight: FontWeight.bold,
                            color: AppColor.grayColor,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: controller.elements.isEmpty
                          ? Center(child: Text("No notifications"))
                          : _createGroupedNotificationListView(
                              controller.elements,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _createGroupedNotificationListView(
      List<Map<String, dynamic>> elements) {
    return GroupedListView<Map<String, dynamic>, String>(
      physics: const BouncingScrollPhysics(),
      addRepaintBoundaries: false,
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: AppPadding.pad6),
      shrinkWrap: false,
      elements: elements,
      groupBy: (element) => element["date"]?.toString() ?? "",
      groupComparator: (value1, value2) => value2.compareTo(value1),
      itemComparator: (item1, item2) =>
          (item1["header"]?.toString() ?? "")
              .compareTo(item2["header"]?.toString() ?? ""),
      order: GroupedListOrder.DESC,
      useStickyGroupSeparators: false,
      stickyHeaderBackgroundColor: Colors.transparent,
      groupSeparatorBuilder: (String value) => Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
          ),
        ),
        child: Text(
          textAlign: TextAlign.start,
          value,
          style: TextStyle(
              fontSize: AppTextSize.textSize14, fontWeight: FontWeight.bold),
        ),
      ),
      itemBuilder: (c, element) {
        return NotifiedItem(
          headerName: element["header"]?.toString() ?? "",
          subHeaderName: element["subHeader"]?.toString() ?? "",
          notificationType: element["notificationType"] is NotificationType
              ? element["notificationType"] as NotificationType
              : NotificationType.newCourses,
          onPress: () {},
        );
      },
    );
  }
}
