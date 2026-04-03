// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';

class AuthTextField extends StatefulWidget {
  final String hintText;
  final bool isSecure;
  final TextEditingController textEditingController;
  const AuthTextField({
    super.key,
    required this.hintText,
    required this.isSecure,
    required this.textEditingController,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscure;

  @override
  void initState() {
    _obscure = widget.isSecure;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pad15, vertical: AppPadding.pad8),
      child: Container(
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            colors: [AppColor.offWhiteColor, AppColor.whiteColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5],
            tileMode: TileMode.clamp,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius15)),
          ),
        ),
        child: TextField(
          expands: false,
          controller: widget.textEditingController,
          obscureText: _obscure,
          style: TextStyle(
              fontSize: AppTextSize.textSize16, color: AppColor.blackColor),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(AppPadding.pad12),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: AppColor.blackColor),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.whiteColor),
              borderRadius: BorderRadius.circular(AppRadius.radius15),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColor.whiteColor),
              borderRadius: BorderRadius.circular(AppRadius.radius15),
            ),
            suffixIcon: widget.isSecure
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColor.blackColor,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
