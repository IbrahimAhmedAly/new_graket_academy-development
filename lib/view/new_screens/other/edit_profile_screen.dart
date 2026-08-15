import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/controller/edit_profile_controller.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/model/education/education_levels_model.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/auth_text_field.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/custom_auth_button.dart';
import 'package:new_graket_acadimy/view/new_widgets/auth_widgets/education_option_card.dart';

/// Lets the student edit the fields PATCH /user/me accepts: name, parent
/// phone, education level and grade. Only what changed is submitted.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<EditProfileController>(
        init: Get.isRegistered<EditProfileController>()
            ? Get.find<EditProfileController>()
            : EditProfileController(),
        builder: (controller) {
          // A save keeps the controller alive for up to 30s. Popping in the
          // meantime deletes it (this GetBuilder is its creator) and disposes
          // the text controllers, so the in-flight response would land on a
          // dead controller and a route that no longer belongs to this screen.
          // `canPop: false` blocks Android system/gesture back and the iOS
          // edge-swipe; the header button below is disabled for the same reason
          // — PopScope cannot veto an imperative Navigator.pop.
          return PopScope(
            canPop: !controller.isSaving,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, canLeave: !controller.isSaving),
                  Expanded(child: _buildBody(context, controller)),
                  if (controller.requestStatus == RequestStatus.success)
                    _buildSaveBar(controller),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Back button + title ──
  Widget _buildHeader(BuildContext context, {required bool canLeave}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppPadding.pad24,
        AppPadding.pad20,
        AppPadding.pad24,
        AppPadding.pad16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: canLeave
                ? () => Navigator.canPop(context)
                    ? Navigator.pop(context)
                    : Get.back()
                : null,
            child: Opacity(
              opacity: canLeave ? 1 : 0.4,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.radius12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(width: AppWidth.w16),
          Expanded(
            child: Text(
              AppStrings.editProfile.tr,
              style: TextStyle(
                fontSize: AppTextSize.textSize20,
                fontWeight: FontWeight.w800,
                color: AppColor.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, EditProfileController controller) {
    if (controller.requestStatus == RequestStatus.loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      );
    }

    if (controller.requestStatus == RequestStatus.failed) {
      return _ErrorState(
        message:
            controller.loadErrorMessage ?? AppStrings.couldNotLoadProfile.tr,
        onRetry: controller.loadProfile,
      );
    }

    if (controller.requestStatus == RequestStatus.none) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Read-only email ──
          if (controller.email.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad16,
                vertical: AppPadding.pad12,
              ),
              decoration: BoxDecoration(
                color: AppColor.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                border: Border.all(
                  color: AppColor.textHint.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.mail_outline_rounded,
                    size: 18,
                    color: AppColor.textHint,
                  ),
                  SizedBox(width: AppWidth.w12),
                  Expanded(
                    child: Text(
                      controller.email,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize14,
                        fontWeight: FontWeight.w500,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: AppColor.textHint,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppHeight.h8),
          ],

          // ── Full name ──
          AuthTextField(
            label: AppStrings.fullName.tr,
            hintText: AppStrings.fullName.tr,
            isSecure: false,
            keyboardType: TextInputType.name,
            textEditingController: controller.nameController,
          ),
          if (controller.nameError != null)
            _FieldError(message: controller.nameError!),

          // ── Parent phone ──
          AuthTextField(
            label: AppStrings.parentPhone.tr,
            hintText: AppStrings.parentPhone.tr,
            isSecure: false,
            keyboardType: TextInputType.phone,
            textEditingController: controller.parentPhoneController,
          ),
          if (controller.parentPhoneError != null)
            _FieldError(message: controller.parentPhoneError!),

          // ── Education level ──
          _PickerField(
            label: AppStrings.educationLevel.tr,
            value: controller.selectedLevel?.name,
            placeholder: AppStrings.notSelected.tr,
            icon: Icons.school_rounded,
            isLoading: controller.isLoadingLevels,
            onTap: () => _showLevelPicker(context, controller),
          ),

          // ── Grade ──
          _PickerField(
            label: AppStrings.grade.tr,
            value: controller.selectedGrade?.name,
            placeholder: controller.selectedLevel?.id == null
                ? AppStrings.pickEducationLevelFirst.tr
                : AppStrings.notSelected.tr,
            icon: Icons.class_rounded,
            enabled: controller.selectedLevel?.id != null,
            isLoading: controller.isLoadingGrades,
            highlight: controller.mustRepickGrade,
            onTap: () => _showGradePicker(context, controller),
          ),

          // ── Level changed → the grade has to be picked again ──
          if (controller.mustRepickGrade) ...[
            SizedBox(height: AppHeight.h8),
            _NoticeBox(
              color: AppColor.starColor,
              icon: Icons.info_outline_rounded,
              message: AppStrings.levelChangedPickGrade.tr,
            ),
          ],

          // ── Server / submit error ──
          if (controller.errorMessage != null) ...[
            SizedBox(height: AppHeight.h12),
            _NoticeBox(
              color: AppColor.errorColor,
              icon: Icons.error_outline_rounded,
              message: controller.errorMessage!,
            ),
          ],

          SizedBox(height: AppHeight.h24),
        ],
      ),
    );
  }

  // ── Pinned save button ──
  Widget _buildSaveBar(EditProfileController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppPadding.pad24,
        AppPadding.pad12,
        AppPadding.pad24,
        AppPadding.pad24,
      ),
      child: CustomAuthButton(
        name: AppStrings.saveChanges.tr,
        isLoading: controller.isSaving,
        onTap: controller.canSave ? () => controller.save() : null,
      ),
    );
  }

  // ─────────────────────────── Pickers ───────────────────────────

  void _showLevelPicker(
    BuildContext context,
    EditProfileController controller,
  ) {
    if (controller.levels.isEmpty && !controller.isLoadingLevels) {
      controller.loadLevels();
    }
    _showOptionSheet(
      context: context,
      title: AppStrings.educationLevel.tr,
      builder: (sheetContext, c) {
        if (c.isLoadingLevels) return const _SheetSpinner();
        if (c.levels.isEmpty) {
          return _SheetEmpty(message: AppStrings.noEducationLevels.tr);
        }
        return _optionList<EducationLevelDatum>(
          items: c.levels,
          isSelected: (level) => c.selectedLevel?.id == level.id,
          titleOf: (level) => level.name ?? '',
          // "label: count" rather than "count label" — Arabic pluralisation
          // doesn't survive an `n == 1 ? singular : plural` ternary.
          subtitleOf: (level) => level.grades.isEmpty
              ? null
              : '${AppStrings.availableGrades.tr}: ${level.grades.length}',
          iconOf: (_) => Icons.school_rounded,
          onSelected: (level) {
            c.selectLevel(level);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  void _showGradePicker(
    BuildContext context,
    EditProfileController controller,
  ) {
    if (controller.selectedLevel?.id == null) return;
    controller.ensureGradesLoaded();
    _showOptionSheet(
      context: context,
      title: AppStrings.grade.tr,
      builder: (sheetContext, c) {
        if (c.isLoadingGrades) return const _SheetSpinner();
        if (c.grades.isEmpty) {
          return _SheetEmpty(message: AppStrings.noGradesInLevel.tr);
        }
        return _optionList<GradeDatum>(
          items: c.grades,
          isSelected: (grade) => c.selectedGrade?.id == grade.id,
          titleOf: (grade) => grade.name ?? '',
          subtitleOf: (_) => null,
          iconOf: (_) => Icons.class_rounded,
          onSelected: (grade) {
            c.selectGrade(grade);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  Widget _optionList<T>({
    required List<T> items,
    required bool Function(T) isSelected,
    required String Function(T) titleOf,
    required String? Function(T) subtitleOf,
    required IconData Function(T) iconOf,
    required void Function(T) onSelected,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: AppPadding.pad8),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: AppHeight.h12),
      itemBuilder: (_, index) {
        final item = items[index];
        return EducationOptionCard(
          title: titleOf(item),
          subtitle: subtitleOf(item),
          icon: iconOf(item),
          isSelected: isSelected(item),
          onTap: () => onSelected(item),
        );
      },
    );
  }

  void _showOptionSheet({
    required BuildContext context,
    required String title,
    required Widget Function(BuildContext, EditProfileController) builder,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return GetBuilder<EditProfileController>(
          builder: (c) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
              ),
              padding: EdgeInsets.fromLTRB(
                AppPadding.pad24,
                AppPadding.pad12,
                AppPadding.pad24,
                MediaQuery.of(sheetContext).padding.bottom + AppPadding.pad24,
              ),
              decoration: BoxDecoration(
                color: AppColor.cardBg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.radius25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Handle bar ──
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColor.textHint.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: AppHeight.h20),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  Flexible(child: builder(sheetContext, c)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Tappable field that opens a bottom-sheet picker ──
class _PickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final bool enabled;
  final bool isLoading;
  final bool highlight;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = (value ?? '').isNotEmpty;
    final borderColor = highlight
        ? AppColor.errorColor.withValues(alpha: 0.6)
        : AppColor.textHint.withValues(alpha: 0.3);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppPadding.pad4,
              bottom: AppPadding.pad6,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppTextSize.textSize12,
                fontWeight: FontWeight.w600,
                color: highlight ? AppColor.errorColor : AppColor.textHint,
              ),
            ),
          ),
          GestureDetector(
            onTap: enabled && !isLoading ? onTap : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad16,
                vertical: AppPadding.pad16,
              ),
              decoration: BoxDecoration(
                color: enabled
                    ? AppColor.scaffoldBg
                    : AppColor.scaffoldBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: enabled ? AppColor.primaryColor : AppColor.textHint,
                  ),
                  SizedBox(width: AppWidth.w12),
                  Expanded(
                    child: Text(
                      hasValue ? value! : placeholder,
                      style: TextStyle(
                        fontSize: AppTextSize.textSize15,
                        fontWeight:
                            hasValue ? FontWeight.w600 : FontWeight.w400,
                        color: hasValue
                            ? AppColor.textPrimary
                            : AppColor.textHint,
                      ),
                    ),
                  ),
                  if (isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.primaryColor,
                      ),
                    )
                  else
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: enabled ? AppColor.textSecondary : AppColor.textHint,
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

// ── Small inline error under a field ──
class _FieldError extends StatelessWidget {
  final String message;
  const _FieldError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppPadding.pad16, bottom: AppPadding.pad4),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: AppColor.errorColor,
          ),
          SizedBox(width: AppWidth.w4),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppTextSize.textSize12,
                fontWeight: FontWeight.w400,
                color: AppColor.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tinted message box (server error / re-pick notice) ──
class _NoticeBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String message;

  const _NoticeBox({
    required this.color,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pad16,
        vertical: AppPadding.pad12,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: AppWidth.w8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: AppTextSize.textSize13,
                fontWeight: FontWeight.w500,
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full-body error state for a failed initial load ──
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.pad24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: AppColor.textHint),
            SizedBox(height: AppHeight.h16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.textSize14,
                fontWeight: FontWeight.w500,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: AppHeight.h20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pad24,
                  vertical: AppPadding.pad12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.radius12),
                ),
                child: Text(
                  AppStrings.refresh.tr,
                  style: TextStyle(
                    fontSize: AppTextSize.textSize14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet states ──
class _SheetSpinner extends StatelessWidget {
  const _SheetSpinner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad40),
      child: Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      ),
    );
  }
}

class _SheetEmpty extends StatelessWidget {
  final String message;
  const _SheetEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 40, color: AppColor.textHint),
          SizedBox(height: AppHeight.h12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTextSize.textSize14,
              fontWeight: FontWeight.w500,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
