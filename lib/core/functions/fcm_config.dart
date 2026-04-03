// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:get/get.dart';
// import 'package:perfectchem/controller/home_controller/settings_controller/order_controller/archived_order_controller.dart';
// import 'package:perfectchem/core/constant/app_routes_name.dart';
//
// import '../../controller/home_controller/settings_controller/order_controller/inprogress_order_controller.dart';
//
// requestPermission () async{
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//
//   if (kDebugMode) {
//     print("User granted permission: ${settings.authorizationStatus}");
//   }
//
// }
//
// FlutterRingtonePlayer flutterRingtonePlayer = FlutterRingtonePlayer();
// fcmConfig(){
//   FirebaseMessaging.instance.subscribeToTopic('users');
//
//   FirebaseMessaging.onMessage.listen((notificationMessage) {
//
//       Get.toNamed(AppRoutesNames.archivedOrder);
//
//     // print("========= notification ===========");
//     // print(notificationMessage.notification!.title);
//     // print(notificationMessage.notification!.body);
//
//     Get.snackbar(notificationMessage.notification!.title!,notificationMessage.notification!.body!);
//
//
//     flutterRingtonePlayer.play(android: AndroidSounds.notification, ios: IosSounds.glass);
//
//     refreshOrderScreen(notificationMessage.data);
//
//   });
// }
//
// void refreshOrderScreen(data) {
//
//   if(Get.currentRoute == "/inProgressOrder" && data["pagename"] == "order"){
//     InProgressOrderControllerImpl controller =  Get.find();
//     controller.refreshInProgressOrders();
//   }else if(Get.currentRoute == "/archivedOrder" && data["pagename"] == "order"){
//     ArchivedOrderControllerImpl  controller =  Get.find();
//     controller.refreshArchivedOrders();
//   }
//
//
// }