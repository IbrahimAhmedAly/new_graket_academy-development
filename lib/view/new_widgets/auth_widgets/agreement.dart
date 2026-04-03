import 'package:flutter/material.dart';
import 'package:new_graket_acadimy/core/constants/app_dimentions.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';

class Agreement extends StatelessWidget {
 final void Function(bool?)? agreementCheckFun;
 final void Function()? goToAgreementFun;
  final bool isAgree ;
  const Agreement({
    super.key,
   required this.agreementCheckFun,
    required this.goToAgreementFun,
    required this.isAgree,
  });



  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppPadding.pad6, vertical: AppPadding.pad6),
          child: Row(
            children: [
              Checkbox(
                value: isAgree,
                onChanged: agreementCheckFun,
              ),
              Text(
                AppStrings.iAgree,
                style: TextStyle(
                  fontSize: AppTextSize.textSize12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: goToAgreementFun,
            child: Text(
              "terms and police ",
              style: TextStyle(
                color: Color.fromARGB(255, 121, 138, 184),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }
}


