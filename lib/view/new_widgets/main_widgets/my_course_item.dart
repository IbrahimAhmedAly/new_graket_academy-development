import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';

class MyCourseItem extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final bool isSaved;
  final double percentage;
  final double rate;
  void Function()? onTap;
  MyCourseItem({
    super.key,
    required this.courseName,
    required this.courseImage,
    required this.isSaved,
    this.percentage = 0.0,
    this.onTap,
    this.rate = 0.0,
  });

  bool _isNetworkImage(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

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
          height: AppHeight.h80,
          width: double.maxFinite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: AppWidth.w90,
                height: AppHeight.h90,
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
                        child: _isNetworkImage(courseImage)
                            ? CachedNetworkImage(
                                imageUrl: courseImage,
                                fit: BoxFit.fill,
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  AssetsPath.courseImage_1,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : Image.asset(
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
              Column(
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
                    padding: EdgeInsets.only(
                      top: AppPadding.pad10,
                    ),
                    width: AppWidth.w170,
                    child: Text(
                      "$percentage %",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    width: AppWidth.w170,
                    child: Stack(
                      children: [
                        Container(
                          width: AppWidth.w145,
                          height: AppHeight.h3,
                          decoration: BoxDecoration(
                            color: AppColor.offWhiteColor,
                            borderRadius: BorderRadius.circular(
                              AppRadius.radius3,
                            ),
                          ),
                        ),
                        Container(
                          width: AppWidth.w145 *
                              (percentage > 100
                                  ? 100
                                  : percentage < 0
                                      ? 0
                                      : percentage) /
                              100,
                          height: AppHeight.h3,
                          decoration: BoxDecoration(
                            color:
                                percentage >= 100 ? AppColor.greenColor : AppColor.savedIconColor,
                            borderRadius: BorderRadius.circular(
                              AppRadius.radius3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.bookmark_outlined,
                  color: isSaved ? AppColor.savedIconColor : Colors.transparent,
                  size: AppRadius.radius25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
