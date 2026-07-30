import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/policy_controller.dart';
import 'package:new_graket_acadimy/core/class/handling_view_data.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

/// Displays a legal document (privacy policy or terms) fetched from the backend.
///
/// The [type] can be passed directly or via `Get.arguments` (so a single screen
/// serves both the `/PrivacyPolicyScreen` and `/TermsScreen` routes).
class PolicyScreen extends StatefulWidget {
  final PolicyType? type;

  const PolicyScreen({super.key, this.type});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late final PolicyType _type;

  @override
  void initState() {
    super.initState();
    // Resolve type from the constructor or the navigation arguments.
    final args = Get.arguments;
    _type = widget.type ??
        (args is PolicyType
            ? args
            : (args is Map && args['type'] is PolicyType
                ? args['type'] as PolicyType
                : PolicyType.privacy));

    final controller = Get.isRegistered<PolicyController>()
        ? Get.find<PolicyController>()
        : Get.put(PolicyController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.load(_type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PolicyController>(
      init: Get.isRegistered<PolicyController>()
          ? Get.find<PolicyController>()
          : PolicyController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.scaffoldBg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppHeight.h8),

                // ── Header ──
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColor.primaryLight,
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius12),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: AppWidth.w12),
                      Expanded(
                        child: Text(
                          controller.titleFor(_type),
                          style: TextStyle(
                            fontSize: AppTextSize.textSize20,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppHeight.h20),

                // ── Content ──
                Expanded(
                  child: HandlingViewData(
                    requestStatus: controller.requestStatus,
                    widget: RefreshIndicator(
                      color: AppColor.primaryColor,
                      onRefresh: () => controller.load(_type),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          AppPadding.pad24,
                          0,
                          AppPadding.pad24,
                          AppPadding.pad24,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(AppPadding.pad20),
                          decoration: BoxDecoration(
                            color: AppColor.cardBg,
                            borderRadius:
                                BorderRadius.circular(AppRadius.radius15),
                          ),
                          child: HtmlWidget(
                            controller.requestStatus == RequestStatus.success
                                ? controller.htmlContent
                                : '',
                            textStyle: TextStyle(
                              fontSize: AppTextSize.textSize15,
                              height: 1.7,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ),
                      ),
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
}
