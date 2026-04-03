import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/constants/colors.dart';
import 'package:new_graket_acadimy/core/constants/image_assets.dart';
import 'package:lottie/lottie.dart';

class Dialogs {
  static void showErrorDialog({
    required RequestStatus status,
    required String message,
    String? errorCode,
    VoidCallback? onRetry,
  }) {
    String title = '';
    String assetLottiPath = AppLottieAssets.error; // Default to error animation
    switch (status) {
      case RequestStatus.loading:
        assetLottiPath = AppLottieAssets.loading;
        title = AppStrings.loading;
        break;
      case RequestStatus.offline:
        assetLottiPath = AppLottieAssets.offline;
        title = message;
        break;
      case RequestStatus.serverFailure:
        assetLottiPath = AppLottieAssets.error;
        title = message;
        break;
      case RequestStatus.failed:
        assetLottiPath = AppLottieAssets.error;
        title = message;
        break;
      case RequestStatus.noInternet:
        assetLottiPath = AppLottieAssets.offline;
        title = message;
        break;
      case RequestStatus.serverException:
        assetLottiPath = AppLottieAssets.error;
        title = message;
        break;
      default:
        title = message;
    }
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child:
                    Lottie.asset(assetLottiPath, width: 200.0, height: 200.0)),
            Center(
                child: Text(
              title,
              style: const TextStyle(fontSize: 20),
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorCode != null) ...[
              SizedBox(height: 10),
              Text(
                'Error Code: $errorCode',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.buttonColor,
                foregroundColor: AppColor.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(AppStrings.ok.tr),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static void showLoadingDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 20),
              Text(
                'Creating your account...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showSuccessDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Success!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to login or home screen
              // Get.offNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}
