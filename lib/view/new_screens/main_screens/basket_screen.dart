import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/basket_controller.dart';
import 'package:new_graket_acadimy/core/class/handling_view_data.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/assets_path.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/basket_item.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/notification_button.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';

class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  String _stringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final result = value is String ? value : value.toString();
    return result.isEmpty ? fallback : result;
  }

  double _doubleValue(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  int _intValue(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  String _formatMoney(double value) => value.toStringAsFixed(2);

  String _formatDuration(int minutes) {
    if (minutes <= 0) return "0 h";
    if (minutes < 60) return "${minutes} m";
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins == 0 ? "${hours} h" : "${hours} h ${mins} m";
  }

  Map<String, dynamic> _extractCourse(Map<String, dynamic> item) {
    final course = item['course'];
    if (course is Map) {
      return Map<String, dynamic>.from(course);
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BasketController>(
      init: Get.isRegistered<BasketController>()
          ? Get.find<BasketController>()
          : BasketController(),
      builder: (controller) {
        return HandlingViewData(
          requestStatus: controller.requestStatus,
          widget: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.pad20,
              vertical: AppPadding.pad25,
            ),
            color: Colors.transparent,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.basket,
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
                    Row(
                      children: [
                        if (controller.items.isNotEmpty)
                          TextButton.icon(
                            onPressed: controller.clearBasket,
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: AppRadius.radius10,
                            ),
                            label: Text(
                              "Clear All",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        NotificationButton(),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppHeight.h20),
                if (controller.basketCount > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: AppPadding.pad10),
                      child: Text(
                        "Items: ${controller.basketCount}",
                        style: TextStyle(
                          fontSize: AppTextSize.textSize12,
                          color: AppColor.grayColor,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: AppPadding.pad10),
                    itemCount: controller.items.length,
                    itemBuilder: (context, index) {
                      final item = controller.items[index];
                      final course = _extractCourse(item);
                      final courseName = _stringValue(
                        course['title'] ?? course['name'],
                        fallback: 'Course',
                      );
                      final courseImage = _stringValue(
                        course['thumbnail'] ?? course['cover'] ?? course['image'],
                        fallback: AssetsPath.courseImage_1,
                      );
                      final price = _doubleValue(
                        course['discountPrice'] ?? course['price'],
                      );
                      final rate = _doubleValue(
                        course['averageRating'] ?? course['rating'],
                      );
                      final duration = _intValue(
                        course['totalDuration'] ?? course['hours'],
                      );
                      final courseId = _stringValue(
                        course['id'] ?? course['_id'],
                      );
                      return BasketItem(
                        courseName: courseName,
                        courseImage: courseImage,
                        price: price,
                        rate: rate,
                        totalTime: _formatDuration(duration),
                        onRemove: courseId.isEmpty
                            ? null
                            : () => controller.removeFromBasket(courseId),
                        onTapExplor: courseId.isEmpty
                            ? null
                            : () {
                                Get.toNamed(
                                  AppRoutesNames.exploreCourseScreen,
                                  arguments: {'courseId': courseId},
                                );
                              },
                      );
                    },
                  ),
                ),
                if (controller.items.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: AppPadding.pad10),
                    child: Container(
                      width: AppWidth.w335,
                      padding: EdgeInsets.all(AppPadding.pad10),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor.withOpacity(0.8),
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius10),
                      ),
                      child: Column(
                        children: [
                          _totalRow(
                              "Total", _formatMoney(controller.totalPrice)),
                          _totalRow("Discounted Total",
                              _formatMoney(controller.totalDiscountPrice)),
                          _totalRow(
                              "Savings", _formatMoney(controller.savings)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _totalRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              color: AppColor.grayColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            "$value EL",
            style: TextStyle(
              fontSize: AppTextSize.textSize12,
              color: AppColor.blackColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
