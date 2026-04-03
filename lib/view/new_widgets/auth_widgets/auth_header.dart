// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';

class AuthHeader extends StatelessWidget {
  String name;
  AuthHeader({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 80, bottom: 0, top: 0),
      child: Container(
        height: AppHeight.h50,
        width: 1.sw / 3,
        decoration: BoxDecoration(
            //color: const Color.fromARGB(255, 252, 252, 252),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.radius25),
              topRight: Radius.circular(AppRadius.radius25),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                color: const Color.fromARGB(255, 97, 97, 97),
              ),
              BoxShadow(
                color: const Color.fromARGB(255, 252, 252, 252),
                spreadRadius: -0.0,
                blurRadius: 5.0,
              ),
            ]),
        child: Padding(
          padding: EdgeInsets.all(AppPadding.pad10),
          child: Text(
            textAlign: TextAlign.center,
            name,
            style: TextStyle(
              color: Color.fromARGB(255, 121, 138, 184),
              fontWeight: FontWeight.bold,
              fontSize: AppTextSize.textSize24,
            ),
          ),
        ),
      ),
    );
  }
}
