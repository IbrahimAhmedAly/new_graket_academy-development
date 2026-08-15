import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:new_graket_acadimy/view/new_widgets/main_widgets/profileElement.dart';

/// Settings hub, pushed from the "Setting" row of the profile tab.
///
/// Deliberately a plain [StatelessWidget]: every row here is pure navigation,
/// so there is nothing to fetch and no controller to register. The screens it
/// pushes own their own state.
///
/// The body is a list of sections — a [_SectionTitle] followed by a
/// [_MenuCard] of [Profileelement] rows — so later batches (Preferences with
/// language + clear cache, a destructive "Delete Account" group, a version
/// footer) can be appended as further blocks without restructuring anything.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      AppStrings.settings.tr,
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

            SizedBox(height: AppHeight.h24),

            // ── Sections ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Account section ──
                    _SectionTitle(title: AppStrings.account.tr),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                      child: _MenuCard(
                        children: [
                          Profileelement(
                            elementName: AppStrings.editProfile.tr,
                            icon: Icons.person_outline_rounded,
                            iconColor: AppColor.primaryColor,
                            onTap: () =>
                                Get.toNamed(AppRoutesNames.editProfileScreen),
                          ),
                          const _MenuDivider(),
                          Profileelement(
                            elementName: AppStrings.changePassword.tr,
                            icon: Icons.lock_outline_rounded,
                            iconColor: AppColor.accentBlue,
                            onTap: () => Get.toNamed(
                                AppRoutesNames.changePasswordScreen),
                          ),
                        ],
                      ),
                    ),

                    // Next batches append their own
                    // `_SectionTitle` + `_MenuCard` pair here — e.g.
                    // Preferences (language, clear cache), then the
                    // destructive "Delete Account" group and a version
                    // footer. Nothing above needs to change.

                    SizedBox(height: AppHeight.h40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
