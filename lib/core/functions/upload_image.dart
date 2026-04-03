//
// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:perfectchem/core/constant/app_strings.dart';
//
// imageUpload()async{
//   final XFile? file =await ImagePicker().pickImage(source: ImageSource.gallery);
//   if(file != null){
//     final size = await file.readAsBytes();
//     if(size.lengthInBytes > 2000000){
//       Get.snackbar( AppStrings.uploadImage, AppStrings.imageSizeErrorMessage, snackPosition: SnackPosition.BOTTOM,);
//       return null;
//     }else{
//       return File(file.path);
//     }
//   }else{
//     return null;
//   }
// }