import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class AuthTextField extends StatefulWidget {
  final String hintText;
  final bool isSecure;
  final TextEditingController textEditingController;
  final TextInputType? keyboardType;
  final String? label;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.isSecure,
    required this.textEditingController,
    this.keyboardType,
    this.label,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isSecure;
    _focusNode = FocusNode()
      ..addListener(() {
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
        controller: widget.textEditingController,
        focusNode: _focusNode,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          fontSize: AppTextSize.textSize15,
          color: AppColor.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.label ?? widget.hintText,
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius12),
            borderSide: BorderSide(
              color: AppColor.primaryColor,
              width: 2,
            ),
          ),
          suffixIcon: widget.isSecure
              ? IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _isFocused ? AppColor.primaryColor : AppColor.textHint,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        ),
      ),
    );
  }
}
