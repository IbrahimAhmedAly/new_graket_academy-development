import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/routing/extention.dart';

class BasketItem extends StatelessWidget {
  final String courseName;
  final String courseImage;
  final double price;
  final double rate;
  final String totalTime;
  void Function()? onTapBuy;
  void Function()? onTapExplor;
  void Function()? onRemove;
  BasketItem({
    super.key,
    required this.courseName,
    required this.courseImage,
    required this.price,
    required this.rate,
    required this.totalTime,
    this.onTapBuy,
    this.onTapExplor,
    this.onRemove,
  });

  bool _isNetworkImage(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad10),
      child: GestureDetector(
        onTap: onTapExplor,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: AppWidth.w305,
          height: AppHeight.h124,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              Container(
                width: AppWidth.w300,
                height: AppHeight.h120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.radius10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radius10),
                  child: _isNetworkImage(courseImage)
                      ? CachedNetworkImage(
                          imageUrl: courseImage,
                          fit: BoxFit.fill,
                          errorWidget: (context, url, error) => Image.asset(
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
                width: AppWidth.w300,
                height: AppHeight.h120,
                decoration: BoxDecoration(
                  color: AppColor.blackColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(
                    AppRadius.radius10,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: AppPadding.pad6,
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
              ),
              Container(
                width: AppWidth.w300,
                height: AppHeight.h120,
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(AppPadding.pad10),
                  child: Row(
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
                          fontSize: AppTextSize.textSize10,
                          fontWeight: FontWeight.normal,
                          color: AppColor.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (onRemove != null)
                Positioned(
                  top: AppPadding.pad6,
                  left: AppPadding.pad6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: AppHeight.h20,
                      height: AppHeight.h20,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(AppRadius.radius20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        size: AppRadius.radius15,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ),
              Container(
                width: AppWidth.w300,
                height: AppHeight.h120,
                alignment: Alignment.bottomRight,
                child: Container(
                  width: AppWidth.w262,
                  height: AppHeight.h50,
                  child: Text(
                    softWrap: true,
                    textAlign: TextAlign.left,
                    courseName,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
              Container(
                width: AppWidth.w305,
                height: AppHeight.h124,
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: AppPadding.pad10),
                      child: Text(
                        "$price \$",
                        style: TextStyle(
                          fontSize: AppTextSize.textSize14,
                          fontWeight: FontWeight.normal,
                          color: AppColor.starColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppWidth.sizeBox,
                    ),
                    GestureDetector(
                      onTap: onTapBuy ??
                          () {
                            context.pushNamed(AppRoutesNames.paymentWayScreen);
                          },
                      child: Container(
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
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    )
    );
  }
}
