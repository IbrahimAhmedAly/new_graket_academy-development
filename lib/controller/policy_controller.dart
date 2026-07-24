import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/policy_data/policy_data.dart';
import 'package:new_graket_acadimy/model/policy/legal_document_model.dart';

/// The two kinds of legal document the app can display.
enum PolicyType { privacy, terms }

class PolicyController extends GetxController {
  final PolicyData policyData = PolicyData(Get.find());
  final MyServices myServices = Get.find();

  RequestStatus requestStatus = RequestStatus.loading;

  /// The HTML content of the currently-loaded document.
  String htmlContent = '';

  String _token() =>
      myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
      '';

  /// Resolve the active app language ('ar' | 'en') for the backend `lang` param.
  String _lang() {
    final code = Get.locale?.languageCode ??
        myServices.sharedPreferences.getString('lang') ??
        'ar';
    return code == 'ar' ? 'ar' : 'en';
  }

  Future<void> load(PolicyType type) async {
    requestStatus = RequestStatus.loading;
    update();

    final token = _token();
    final lang = _lang();

    final response = type == PolicyType.privacy
        ? await policyData.getPrivacy(token: token, lang: lang)
        : await policyData.getTerms(token: token, lang: lang);

    requestStatus = response.$1;

    if (requestStatus == RequestStatus.success &&
        response.$2 is Map<String, dynamic>) {
      try {
        final model = LegalDocumentModel.fromJson(
          response.$2 as Map<String, dynamic>,
        );
        htmlContent = model.data?.data?.content ?? '';
        // A document with no body should read as empty, not as content.
        if (htmlContent.trim().isEmpty) {
          requestStatus = RequestStatus.failed;
        }
      } catch (_) {
        htmlContent = '';
        requestStatus = RequestStatus.failed;
      }
    }

    update();
  }

  /// Title shown in the screen header for a given document type.
  String titleFor(PolicyType type) =>
      type == PolicyType.privacy ? AppStrings.privacy.tr : AppStrings.terms.tr;
}
