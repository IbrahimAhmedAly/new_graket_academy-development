import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:new_graket_acadimy/core/services/services.dart';

class ChangeLanguageButton extends StatefulWidget {
  const ChangeLanguageButton({
    super.key,
  });

  @override
  State<ChangeLanguageButton> createState() => _ChangeLanguageButtonState();
}

class _ChangeLanguageButtonState extends State<ChangeLanguageButton> {
  final MyServices _services = Get.find<MyServices>();

  @override
  Widget build(BuildContext context) {
   String dropValue = Get.locale?.languageCode ?? "en";
    return DropdownMenu(
        onSelected: (value) {
          if (value == null) {
            return;
          }
          _services.sharedPreferences.setString("lang", value);
          Get.updateLocale(Locale(value));
          setState(() {});
        } ,
         trailingIcon:dropValue == "en"? Text("ع" ,style: TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold),) : Text("E",style: TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold),) ,
        dropdownMenuEntries: [
          DropdownMenuEntry(value: "en", label: "English"),
          DropdownMenuEntry(value: "ar", label: "Arabic"),
        ]);
  }
}
