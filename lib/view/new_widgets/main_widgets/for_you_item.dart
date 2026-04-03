import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

import '../../../core/constants/assets_path.dart';

class ForYouItem extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final double price;
  final double discountPrice;
  final double rate;
  final String totalTime;
  final bool isSelected;
  final bool isSaved;
  final void Function()? onTapSave;
  final void Function()? onTap;
  const ForYouItem({
    super.key,
    required this.isSelected,
    required this.courseName,
    required this.courseImage,
    required this.price,
    required this.rate,
    required this.totalTime,
    required this.discountPrice,
    required this.isSaved,
    required this.onTapSave,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.all(isSelected ? 0.0 : AppPadding.pad12),
        height: isSelected ? AppHeight.h206 : AppHeight.h196,
        width: isSelected ? AppWidth.w258 : AppWidth.w245,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.radius10),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: AppHeight.h206,
              width: AppWidth.w258,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.radius10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius10),
                child: CachedNetworkImage(
                  imageUrl: courseImage,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.radius10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                   errorWidget: (context, error, stackTrace) => Image.asset(AssetsPath.ic , fit: BoxFit.cover,),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius10),
              clipBehavior: Clip.hardEdge,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  height: AppHeight.h82,
                  width: AppWidth.w258,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppRadius.radius10),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.pad10,
                          vertical: AppPadding.pad10,
                        ),
                        child: Text(
                          courseName,
                          style: TextStyle(
                            fontSize: AppTextSize.textSize14,
                            fontWeight: FontWeight.bold,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(AppPadding.pad6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: AppWidth.w39,
                              height: AppHeight.h20,
                              decoration: BoxDecoration(
                                color: AppColor.whiteColor,
                                borderRadius: BorderRadius.only(
                                  bottomLeft:
                                      Radius.circular(AppRadius.radius10),
                                  topRight: Radius.circular(AppRadius.radius10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: AppColor.starColor,
                                    size: AppRadius.radius10,
                                  ),
                                  SizedBox(
                                    width: AppWidth.sizeBox,
                                  ),
                                  Text(
                                    "$rate",
                                    style: TextStyle(
                                      fontSize: AppTextSize.textSize10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.av_timer_rounded,
                                  color: AppColor.whiteColor,
                                  size: AppRadius.radius15,
                                ),
                                SizedBox(
                                  width: AppWidth.sizeBox,
                                ),
                                Text(
                                  totalTime,
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize12,
                                    fontWeight: FontWeight.normal,
                                    color: AppColor.whiteColor,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "$price \$",
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize10,
                                    fontWeight: FontWeight.normal,
                                    color: AppColor.whiteColor,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  width: AppWidth.sizeBox,
                                ),
                                Text(
                                  "$discountPrice \$",
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize14,
                                    fontWeight: FontWeight.normal,
                                    color: AppColor.starColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              height: AppHeight.h206,
              width: AppWidth.w258,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.radius10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onTapSave,
                    child: Icon(
                      Icons.bookmark_outlined,
                      color: isSaved
                          ? AppColor.savedIconColor
                          : AppColor.whiteColor.withOpacity(0.8),
                      size: AppRadius.radius30,
                    ),
                  ),
                  Container(
                    width: AppWidth.w57,
                    height: AppHeight.h24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColor.savedIconColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.radius10),
                        topRight: Radius.circular(AppRadius.radius10),
                        bottomLeft: Radius.circular(AppRadius.radius10),
                      ),
                    ),
                    child: Text(
                      AppStrings.buyNow,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize10,
                        fontWeight: FontWeight.bold,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            !isSelected
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.radius10),
                    clipBehavior: Clip.hardEdge,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        height: AppHeight.h206,
                        width: AppWidth.w258,
                        decoration: BoxDecoration(
                          color: AppColor.whiteColor.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius10),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: 0,
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }
}
