import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/change_password_controller.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';

/// Lets a signed-in user change their password from Settings.
///
/// The obscure state of every field lives on [ChangePasswordController] rather
/// than inside the field widget, so the shared `AuthTextField` (which owns its
/// own toggle and its own hard-coded English validation) is not reused here —
/// [_PasswordField] below mirrors its exact visual decoration instead.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<ChangePasswordController>(
        init: Get.isRegistered<ChangePasswordController>()
            ? Get.find<ChangePasswordController>()
            : ChangePasswordController(),
        assignId: true,
        builder: (controller) {
          final isSubmitting = controller.isSubmitting;

          // The back chevron below is only one of three ways off this screen.
          // Android system/gesture back and the iOS interactive edge-swipe (on
          // by default — this route sets no `popGesture`) would otherwise pop
          // mid-request and leave the in-flight Get.back() to hit whatever
          // route ended up on top. Block all three while submitting.
          return PopScope(
            canPop: !isSubmitting,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppHeight.h8),

                    // ── Header: back button + title ──
                    Row(
                      children: [
                        GestureDetector(
                          onTap: isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
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
                            AppStrings.changePassword.tr,
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

                    SizedBox(height: AppHeight.h32),

                    // ── Current password ──
                    _PasswordField(
                      label: AppStrings.currentPassword.tr,
                      hint: AppStrings.passwordHint.tr,
                      controller: controller.currentPasswordController,
                      obscure: controller.obscureCurrentPassword,
                      onToggleObscure:
                          controller.toggleCurrentPasswordVisibility,
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                    ),

                    // ── New password ──
                    _PasswordField(
                      label: AppStrings.newPassword.tr,
                      hint: AppStrings.enterNewPassword.tr,
                      controller: controller.newPasswordController,
                      obscure: controller.obscureNewPassword,
                      onToggleObscure: controller.toggleNewPasswordVisibility,
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.next,
                    ),

                    // ── Confirm new password ──
                    _PasswordField(
                      label: AppStrings.confirmNewPassword.tr,
                      hint: AppStrings.reEnterNewPassword.tr,
                      controller: controller.confirmPasswordController,
                      obscure: controller.obscureConfirmPassword,
                      onToggleObscure:
                          controller.toggleConfirmPasswordVisibility,
                      enabled: !isSubmitting,
                      textInputAction: TextInputAction.done,
                      onSubmitted: controller.canSubmit
                          ? (_) => controller.changePassword()
                          : null,
                    ),

                    SizedBox(height: AppHeight.h12),

                    // ── Minimum-length hint (same rule sign-up uses) ──
                    Padding(
                      padding: EdgeInsets.only(left: AppPadding.pad4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: AppColor.textHint,
                          ),
                          SizedBox(width: AppWidth.w4),
                          Expanded(
                            child: Text(
                              '${AppStrings.valueCannotBeLessThan.tr} '
                              '${ChangePasswordController.minPasswordLength}',
                              style: TextStyle(
                                fontSize: AppTextSize.textSize12,
                                fontWeight: FontWeight.w400,
                                color: AppColor.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppHeight.h32),

                    // ── Submit ──
                    CustomAuthButton(
                      name: AppStrings.changePassword.tr,
                      isLoading: isSubmitting,
                      onTap: controller.canSubmit
                          ? () => controller.changePassword()
                          : null,
                    ),

                    // ── Inline error (server wording shown verbatim) ──
                    if (controller.errorMessage != null) ...[
                      SizedBox(height: AppHeight.h12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.pad16,
                          vertical: AppPadding.pad12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.errorColor.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppRadius.radius12),
                          border: Border.all(
                            color: AppColor.errorColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: AppColor.errorColor,
                              size: 18,
                            ),
                            SizedBox(width: AppWidth.w8),
                            Expanded(
                              child: Text(
                                controller.errorMessage!,
                                style: TextStyle(
                                  fontSize: AppTextSize.textSize13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: AppHeight.h40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Obscured text field whose visibility toggle is driven from the controller.
///
/// Decoration is kept byte-for-byte in line with
/// `lib/view/new_widgets/auth_widgets/auth_text_field.dart` so the form reads
/// as part of the same design language as login / sign-up.
class _PasswordField extends StatefulWidget {
  final String label;

  /// Each field gets its own placeholder — all three used to share the
  /// generic "ادخل كلمة السر", which reads wrong on New and Confirm.
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.enabled = true,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        if (!mounted) return;
        setState(() => _isFocused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad8),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscure,
        enabled: widget.enabled,
        enableSuggestions: false,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(
          fontSize: AppTextSize.textSize15,
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          labelStyle: TextStyle(
            color: _isFocused ? AppColor.primaryColor : AppColor.textHint,
            fontSize: AppTextSize.textSize14,
            fontWeight: FontWeight.w400,
          ),
          floatingLabelStyle: TextStyle(
            color: AppColor.primaryColor,
            fontSize: AppTextSize.textSize12,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: AppColor.textHint,
            fontSize: AppTextSize.textSize14,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppPadding.pad16,
            vertical: AppPadding.pad16,
          ),
          filled: true,
          fillColor: _isFocused
              ? AppColor.primaryLight.withValues(alpha: 0.5)
              : AppColor.scaffoldBg,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            borderSide: BorderSide(
              color: AppColor.textHint.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            borderSide: BorderSide(
              color: AppColor.textHint.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            borderSide: BorderSide(
              color: AppColor.primaryColor,
              width: 2,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              widget.obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: _isFocused ? AppColor.primaryColor : AppColor.textHint,
              size: 20,
            ),
            onPressed: widget.enabled ? widget.onToggleObscure : null,
          ),
        ),
      ),
    );
  }
}
