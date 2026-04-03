import 'package:get/get.dart';
import '../constants/app_strings.dart';

valid(String type, int min, int max, String value) {
  if (type == AppStrings.email) {
    if (!GetUtils.isEmail(value)) {
      return AppStrings.notValidEmail.tr;
    }
  }
  if (type == AppStrings.userName) {
    bool isUsername =   RegExp(r'^[a-zA-Z0-9 ]{3,}$').hasMatch(value);
    if (!isUsername) {
      return AppStrings.notValidUserName.tr ;
    }
  }
  if (type == AppStrings.phoneNumber) {
    if (!GetUtils.isPhoneNumber(value)) {
      return AppStrings.notValidPhoneNum.tr;
    }
  }
  // if(type == AppStrings.password){
  //   if(GetUtils.isPassport(value)){
  //     return AppStrings.notValidPassword;
  //   }
  // }
  if(value.isEmpty){
    return 'its cant be empty';
  }
  if (value.length < min){
    return '${AppStrings.valueCannotBeLessThan.tr}$min' ;
  }
  if (value.length > max){
    return '${AppStrings.valueCannotBeMoreThan.tr}$max' ;
  }

}
