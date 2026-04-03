import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/constants/image_assets.dart';

class CategorizedCourseItem extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final double price;
  final double? discountPrice;
  final double rate;
  final String totalTime;
  final void Function()? onTap;
  const CategorizedCourseItem(
      {super.key,
      required this.courseName,
      required this.courseImage,
      required this.price,
      required this.discountPrice,
      required this.rate,
      required this.totalTime,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: AppHeight.h150,
            width: AppWidth.w170,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.radius10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius10),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: courseImage,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>  Image.asset(
                  AppImageAssets.courseErrorImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radius10),
            clipBehavior: Clip.hardEdge,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                height: AppHeight.h65,
                width: AppWidth.w170,
                decoration: BoxDecoration(
                  color: AppColor.whiteColor.withOpacity(0.5),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        courseName,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize12,
                          fontWeight: FontWeight.bold,
                          color: AppColor.blackColor,
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
                                bottomLeft: Radius.circular(AppRadius.radius10),
                                topRight: Radius.circular(AppRadius.radius10),
                              ),
                            ),
                            child: Row(
                              spacing: AppWidth.w1,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppColor.starColor,
                                  size: AppRadius.radius12,
                                ),
                                Text(
                                  "$rate",
                                  style: TextStyle(
                                    fontSize: AppTextSize.textSize12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Text(
                              //   "$price \$",
                              //   style: TextStyle(
                              //     fontSize: AppTextSize.textSize10,
                              //     fontWeight: FontWeight.normal,
                              //     color: AppColor.grayColor,
                              //     decoration: TextDecoration.lineThrough,
                              //     decorationColor: AppColor.grayColor,
                              //   ),
                              // ),
                              SizedBox(
                                width: AppWidth.sizeBox,
                              ),
                              Text(
                                "$price EL",
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize12,
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
            alignment: Alignment.topRight,
            height: AppHeight.h150,
            width: AppWidth.w170,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.radius10),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: AppPadding.pad10, top: AppPadding.pad10),
              child: Row(
                spacing: AppWidth.w1,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.av_timer_rounded,
                    color: AppColor.whiteColor,
                    size: AppRadius.radius20,
                  ),
                  Text(
                    totalTime,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize15,
                      fontWeight: FontWeight.normal,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
