import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

enum AuthFieldType { name, email, password, none }

class AuthTextField extends StatefulWidget {
  final String hintText;
  final bool isSecure;
  final TextEditingController textEditingController;
  final TextInputType? keyboardType;
  final String? label;
  final AuthFieldType fieldType;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.isSecure,
    required this.textEditingController,
    this.keyboardType,
    this.label,
    this.fieldType = AuthFieldType.none,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _touched = false; // only show error after first blur
  String? _error;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isSecure;
    _focusNode = FocusNode()
      ..addListener(() {
        final hasFocus = _focusNode.hasFocus;
        setState(() {
          _isFocused = hasFocus;
          // validate on blur
          if (!hasFocus && !_touched) _touched = true;
          if (_touched) _error = _validate(widget.textEditingController.text);
        });
      });
    widget.textEditingController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (_touched) {
      setState(() {
        _error = _validate(widget.textEditingController.text);
      });
    }
  }

  String? _validate(String value) {
    final trimmed = value.trim();
    switch (widget.fieldType) {
      case AuthFieldType.name:
        if (trimmed.isEmpty) return "Full name is required";
        if (trimmed.length < 2) return "Name must be at least 2 characters";
        return null;
      case AuthFieldType.email:
        if (trimmed.isEmpty) return "Email is required";
        final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(trimmed)) return "Enter a valid email address";
        return null;
      case AuthFieldType.password:
        if (value.isEmpty) return "Password is required";
        if (value.length < 6) return "Password must be at least 6 characters";
        return null;
      case AuthFieldType.none:
        return null;
    }
  }

  bool get hasError => _touched && _error != null;

  @override
  void dispose() {
    widget.textEditingController.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppPadding.pad8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
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
                color: hasError
                    ? AppColor.errorColor
                    : _isFocused
                        ? AppColor.primaryColor
                        : AppColor.textHint,
                fontSize: AppTextSize.textSize14,
                fontWeight: FontWeight.w400,
              ),
              floatingLabelStyle: TextStyle(
                color: hasError ? AppColor.errorColor : AppColor.primaryColor,
                fontSize: AppTextSize.textSize12,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppPadding.pad16,
                vertical: AppPadding.pad16,
              ),
              filled: true,
              fillColor: hasError
                  ? AppColor.errorColor.withValues(alpha: 0.05)
                  : _isFocused
                      ? AppColor.primaryLight.withValues(alpha: 0.5)
                      : AppColor.scaffoldBg,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                borderSide: BorderSide(
                  color: hasError
                      ? AppColor.errorColor.withValues(alpha: 0.6)
                      : AppColor.textHint.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.radius12),
                borderSide: BorderSide(
                  color: hasError ? AppColor.errorColor : AppColor.primaryColor,
                  width: 2,
                ),
              ),
              suffixIcon: widget.isSecure
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: hasError
                            ? AppColor.errorColor
                            : _isFocused
                                ? AppColor.primaryColor
                                : AppColor.textHint,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
            ),
          ),
          // ── Inline error message ──
          if (hasError)
            Padding(
              padding: EdgeInsets.only(
                left: AppPadding.pad16,
                top: AppPadding.pad4,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 12,
                    color: AppColor.errorColor,
                  ),
                  SizedBox(width: AppWidth.w4),
                  Text(
                    _error!,
                    style: TextStyle(
                      fontSize: AppTextSize.textSize12,
                      color: AppColor.errorColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
