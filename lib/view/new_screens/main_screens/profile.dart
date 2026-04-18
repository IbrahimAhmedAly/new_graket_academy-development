import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/profile_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/common/widgets/shimmer_loading.dart';
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

  void _showLogoutConfirmation(
      BuildContext context, ProfileController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          AppPadding.pad24,
          AppPadding.pad24,
          AppPadding.pad24,
          MediaQuery.of(context).padding.bottom + AppPadding.pad24,
        ),
        decoration: BoxDecoration(
          color: AppColor.cardBg,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.radius25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ──
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.textHint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppHeight.h24),

            // ── Icon ──
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColor.errorColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: AppColor.errorColor,
                size: 26,
              ),
            ),
            SizedBox(height: AppHeight.h16),

            // ── Title ──
            Text(
              "Log out",
              style: TextStyle(
                fontSize: AppTextSize.textSize18,
                fontWeight: FontWeight.w700,
                color: AppColor.textPrimary,
              ),
            ),
            SizedBox(height: AppHeight.h8),

            // ── Description ──
            Text(
              "Are you sure you want to log out?\nYou can always log back in.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                fontWeight: FontWeight.w400,
                color: AppColor.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: AppHeight.h24),

            // ── Buttons row ──
            Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: AppHeight.h48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.scaffoldBg,
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius12),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: AppTextSize.textSize15,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppWidth.w12),
                // Confirm logout
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      controller.logout();
                    },
                    child: Container(
                      height: AppHeight.h48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.errorColor,
                        borderRadius:
                            BorderRadius.circular(AppRadius.radius12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColor.errorColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        "Log out",
                        style: TextStyle(
                          fontSize: AppTextSize.textSize15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : ProfileController(),
      builder: (controller) {
        if (controller.requestStatus == RequestStatus.loading) {
          return const _ProfileSkeleton();
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height:
                      MediaQuery.of(context).padding.top + AppHeight.h16),

              // ── Page title ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                child: Text(
                  AppStrings.profile,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize24,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              SizedBox(height: AppHeight.h24),

              // ── Avatar + Name card ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppPadding.pad20),
                  decoration: BoxDecoration(
                    color: AppColor.cardBg,
                    borderRadius: BorderRadius.circular(AppRadius.radius20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withValues(alpha: 0.07),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ── Avatar ──
                      Stack(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.primaryColor
                                    .withValues(alpha: 0.2),
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: _isNetworkImage(controller.avatar)
                                  ? CachedNetworkImage(
                                      imageUrl: controller.avatar,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          Image.asset(
                                        AssetsPath.profile,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      AssetsPath.profile,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => appPrint("Edit Profile Photo"),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColor.cardBg,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppHeight.h12),

                      // ── Name ──
                      Text(
                        controller.name,
                        style: TextStyle(
                          fontSize: AppTextSize.textSize18,
                          fontWeight: FontWeight.w700,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppHeight.h4),

                      // ── Email ──
                      Text(
                        controller.email.isNotEmpty ? controller.email : "—",
                        style: TextStyle(
                          fontSize: AppTextSize.textSize13,
                          fontWeight: FontWeight.w400,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppHeight.h24),

              // ── General section ──
              _SectionTitle(title: "General"),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                child: _MenuCard(
                  children: [
                    Profileelement(
                      elementName: AppStrings.setting,
                      icon: Icons.settings_outlined,
                      iconColor: AppColor.primaryColor,
                      onTap: () => appPrint("Setting"),
                    ),
                    const _MenuDivider(),
                    Profileelement(
                      elementName: AppStrings.privacy,
                      icon: Icons.shield_outlined,
                      iconColor: AppColor.priceColor,
                      onTap: () => appPrint("privacy"),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppHeight.h20),

              // ── Support section ──
              _SectionTitle(title: "Support"),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                child: _MenuCard(
                  children: [
                    Profileelement(
                      elementName: AppStrings.support,
                      icon: Icons.help_outline_rounded,
                      iconColor: AppColor.accentBlue,
                      onTap: () => controller.contactUs(),
                    ),
                    const _MenuDivider(),
                    Profileelement(
                      elementName: AppStrings.contactUs,
                      icon: Icons.chat_bubble_outline_rounded,
                      iconColor: AppColor.accentBlue,
                      onTap: () => controller.contactUs(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppHeight.h20),

              // ── Logout ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                child: _MenuCard(
                  children: [
                    Profileelement(
                      elementName: AppStrings.logOut,
                      icon: Icons.logout_rounded,
                      iconColor: AppColor.errorColor,
                      isDestructive: true,
                      onTap: () => _showLogoutConfirmation(context, controller),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppHeight.h120),
            ],
          ),
        );
      },
    );
  }
}

// ── Section title ──
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppPadding.pad24,
        right: AppPadding.pad24,
        bottom: AppPadding.pad8,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppTextSize.textSize13,
          fontWeight: FontWeight.w600,
          color: AppColor.textHint,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── White card container for menu items ──
class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pad16,
        vertical: AppPadding.pad4,
      ),
      decoration: BoxDecoration(
        color: AppColor.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.radius15),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Divider between menu items ──
class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColor.scaffoldBg,
    );
  }
}

// ── Shimmer skeleton for loading state ──
class _ProfileSkeleton extends StatefulWidget {
  const _ProfileSkeleton();

  @override
  State<_ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<_ProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: MediaQuery.of(context).padding.top + AppHeight.h16),

            // Title skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
              child: ShimmerBox(width: 100, height: 24),
            ),

            SizedBox(height: AppHeight.h24),

            // Avatar card skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppPadding.pad20),
                decoration: BoxDecoration(
                  color: AppColor.cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.radius20),
                ),
                child: Column(
                  children: [
                    ShimmerBox(width: 84, height: 84, borderRadius: 42),
                    SizedBox(height: AppHeight.h12),
                    ShimmerBox(width: 140, height: 18),
                    SizedBox(height: AppHeight.h8),
                    ShimmerBox(width: 180, height: 13),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppHeight.h24),

            // Section title skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
              child: ShimmerBox(width: 70, height: 13),
            ),
            SizedBox(height: AppHeight.h8),

            // Menu card skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppPadding.pad16),
                decoration: BoxDecoration(
                  color: AppColor.cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.radius15),
                ),
                child: Column(
                  children: [
                    _menuRowSkeleton(),
                    SizedBox(height: AppHeight.h20),
                    _menuRowSkeleton(),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppHeight.h20),

            // Section title skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
              child: ShimmerBox(width: 60, height: 13),
            ),
            SizedBox(height: AppHeight.h8),

            // Menu card skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppPadding.pad16),
                decoration: BoxDecoration(
                  color: AppColor.cardBg,
                  borderRadius: BorderRadius.circular(AppRadius.radius15),
                ),
                child: Column(
                  children: [
                    _menuRowSkeleton(),
                    SizedBox(height: AppHeight.h20),
                    _menuRowSkeleton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuRowSkeleton() {
    return Row(
      children: [
        ShimmerBox(width: 40, height: 40, borderRadius: 12),
        SizedBox(width: AppWidth.w12),
        Expanded(child: ShimmerBox(width: double.infinity, height: 14)),
      ],
    );
  }
}
