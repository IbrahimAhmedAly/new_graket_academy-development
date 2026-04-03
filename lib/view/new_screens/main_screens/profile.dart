import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/profile_controller.dart';
import 'package:new_graket_acadimy/core/class/handling_view_data.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/debug_print.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/profileElement.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  bool _isNetworkImage(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : ProfileController(),
      builder: (controller) {
        return HandlingViewData(
          requestStatus: controller.requestStatus,
          widget: Container(
            width: 1.sw,
            padding: EdgeInsets.symmetric(
                vertical: AppPadding.pad30, horizontal: AppPadding.pad25),
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 1.sw,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.profile,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize32,
                          fontWeight: FontWeight.bold,
                          color: AppColor.grayColor,
                        ),
                      ),
                      Text(
                        AppStrings.learnWithGrakeT,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize13,
                          fontWeight: FontWeight.bold,
                          color: AppColor.grayColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppHeight.h3),
                Stack(
                  children: [
                    SizedBox(
                      width: AppWidth.w154,
                      height: AppHeight.h156,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.radius100),
                        child: _isNetworkImage(controller.avatar)
                            ? CachedNetworkImage(
                                imageUrl: controller.avatar,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) =>
                                    const Image(
                                  image: AssetImage(
                                    AssetsPath.profile,
                                  ),
                                ),
                              )
                            : const Image(
                                image: AssetImage(
                                  AssetsPath.profile,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: GestureDetector(
                        onTap: () {
                          appPrint("Edit Profile Photo");
                        },
                        child: Container(
                          width: AppWidth.w50,
                          height: AppHeight.h40,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.radius40),
                              color: AppColor.mainScreenButtons),
                          child: Icon(
                            Icons.mode_edit_outline_sharp,
                            color: AppColor.whiteColor,
                            size: AppRadius.radius24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppHeight.h3),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      controller.name,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.grayColor,
                      ),
                    ),
                    Text(
                      controller.email.isNotEmpty
                          ? controller.email
                          : "—",
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        fontWeight: FontWeight.bold,
                        color: AppColor.grayColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppHeight.h10),
                Column(
                  children: [
                    Profileelement(
                      elementName: AppStrings.setting,
                      icon: Icons.settings,
                      iconColor: AppColor.settingColor,
                      onTap: () {
                        appPrint("Setting");
                      },
                    ),
                    Profileelement(
                      elementName: AppStrings.support,
                      icon: Icons.help_center_rounded,
                      iconColor: AppColor.supportColor,
                      onTap: () {
                        controller.contactUs();
                      },
                    ),
                    Profileelement(
                      elementName: AppStrings.privacy,
                      icon: Icons.privacy_tip,
                      iconColor: AppColor.privacyColor,
                      onTap: () {
                        appPrint("privacy");
                      },
                    ),
                    Profileelement(
                      elementName: AppStrings.contactUs,
                      icon: Icons.phone_in_talk_rounded,
                      iconColor: AppColor.contactUsColor,
                      onTap: () {
                        controller.contactUs();
                      },
                    ),
                    Profileelement(
                      elementName: AppStrings.logOut,
                      icon: Icons.logout,
                      iconColor: AppColor.logOutColor,
                      onTap: () {
                        controller.logout();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
