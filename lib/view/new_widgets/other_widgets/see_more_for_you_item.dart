import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class SeeMoreForYouItem extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final bool isSaved;
  final double rate;
  final double price;
  final double discountPrice;
  final String totalTime;
  void Function()? onTap;
  SeeMoreForYouItem({
    super.key,
    required this.courseName,
    required this.courseImage,
    required this.isSaved,
    this.onTap,
    this.rate = 0.0,
    required this.price,
    required this.discountPrice,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppPadding.pad8,
      ),
      child: GestureDetector(
        onTap: () {
          onTap?.call();
        },
        child: Container(
          height: AppHeight.h90,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: AppColor.whiteColor.withAlpha(200),
            borderRadius: BorderRadius.circular(AppRadius.radius10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: AppWidth.w90,
                height: AppWidth.w90,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.radius10),
                ),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Container(
                      width: AppWidth.w90,
                      height: AppHeight.h90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.radius10),
                        child: Image.asset(
                          courseImage,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Container(
                      width: AppWidth.w90,
                      height: AppHeight.h90,
                      decoration: BoxDecoration(
                        color: AppColor.blackColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppRadius.radius10,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: AppPadding.pad6,
                        bottom: AppPadding.pad6,
                      ),
                      child: Container(
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
                    )
                  ],
                ),
              ),
              Container(
                width: AppWidth.w245,
                height: AppHeight.h80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: AppWidth.w170,
                          child: Text(
                            softWrap: true,
                            textAlign: TextAlign.left,
                            courseName,
                            style: TextStyle(
                              fontSize: AppTextSize.textSize14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topRight,
                          child: Icon(
                            Icons.bookmark_outlined,
                            color:
                                isSaved ? AppColor.savedIconColor : Colors.transparent,
                            size: AppRadius.radius25,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.av_timer_rounded,
                              color: AppColor.blackColor,
                              size: AppRadius.radius15,
                            ),
                            SizedBox(
                              width: AppWidth.sizeBox,
                            ),
                            Text(
                              totalTime,
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.normal,
                                color: AppColor.blackColor,
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
                                fontSize: AppTextSize.textSize12,
                                fontWeight: FontWeight.bold,
                                color: AppColor.blackColor,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColor.blackColor,
                              ),
                            ),
                            SizedBox(
                              width: AppWidth.sizeBox,
                            ),
                            Text(
                              "$discountPrice \$",
                              style: TextStyle(
                                fontSize: AppTextSize.textSize14,
                                fontWeight: FontWeight.bold,
                                color:AppColor. starColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
