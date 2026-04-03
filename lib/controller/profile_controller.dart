import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/profile_data/profile_data.dart';
import 'package:new_graket_acadimy/routing/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileController extends GetxController {
  final ProfileData profileData = ProfileData(Get.find());
  final MyServices myServices = Get.find();

  RequestStatus requestStatus = RequestStatus.loading;
  String name = 'Unknown';
  String email = 'Unknown';
  String avatar = '';

  @override
  void onInit() {
    super.onInit();
    _loadLocal();
    fetchProfile();
  }

  void _loadLocal() {
    final localName =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userNameKey) ??
            '';
    final localEmail =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userEmailKey) ??
            '';
    name = localName.trim().isEmpty ? 'Unknown' : localName;
    email = localEmail.trim().isEmpty ? 'Unknown' : localEmail;
    avatar = '';
    requestStatus = RequestStatus.success;
    update();
  }

  String _stringValue(dynamic value) {
    if (value == null) return '';
    return value is String ? value : value.toString();
  }

  Map<String, dynamic> _extractUserMap(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map) {
      if (data['user'] is Map) {
        return Map<String, dynamic>.from(data['user']);
      }
      if (data['profile'] is Map) {
        return Map<String, dynamic>.from(data['profile']);
      }
      final inner = data['data'];
      if (inner is Map) {
        if (inner['user'] is Map) {
          return Map<String, dynamic>.from(inner['user']);
        }
        if (inner['profile'] is Map) {
          return Map<String, dynamic>.from(inner['profile']);
        }
        return Map<String, dynamic>.from(inner);
      }
      return Map<String, dynamic>.from(data);
    }
    if (raw['user'] is Map) {
      return Map<String, dynamic>.from(raw['user']);
    }
    if (raw['profile'] is Map) {
      return Map<String, dynamic>.from(raw['profile']);
    }
    return raw;
  }

  Future<void> fetchProfile() async {
    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            '';
    if (token.isEmpty) return;

    requestStatus = RequestStatus.loading;
    update();

    final response = await profileData.getProfile(token: token);
    final status = response.$1;
    if (status != RequestStatus.success || response.$2 is! Map<String, dynamic>) {
      requestStatus = RequestStatus.success;
      update();
      return;
    }

    final raw = response.$2 as Map<String, dynamic>;
    final user = _extractUserMap(raw);

    var newName = _stringValue(user['name'] ??
        user['displayName'] ??
        user['fullName'] ??
        user['username']);
    final newEmail = _stringValue(user['email'] ?? user['mail']);
    final newAvatar = _stringValue(user['avatar'] ??
        user['image'] ??
        user['photo'] ??
        user['avatarUrl'] ??
        user['photoUrl'] ??
        user['profileImage']);

    if (newName.isEmpty) {
      final first = _stringValue(user['firstName']);
      final last = _stringValue(user['lastName']);
      final combined = [first, last].where((value) => value.isNotEmpty).join(' ');
      if (combined.isNotEmpty) {
        newName = combined;
      }
    }

    if (newName.isNotEmpty) name = newName;
    if (newEmail.isNotEmpty) email = newEmail;
    if (newAvatar.isNotEmpty) avatar = newAvatar;

    requestStatus = RequestStatus.success;
    update();
  }

  void logout() {
    if (Get.isRegistered<MyServices>()) {
      final prefs = Get.find<MyServices>().sharedPreferences;
      prefs
        ..remove(AppSharedPrefKeys.userTokenKey)
        ..remove(AppSharedPrefKeys.refreshTokenKey)
        ..remove(AppSharedPrefKeys.userEmailKey)
        ..remove(AppSharedPrefKeys.userNameKey)
        ..remove(AppSharedPrefKeys.userPhoneKey)
        ..remove(AppSharedPrefKeys.userIdKey)
        ..remove(AppSharedPrefKeys.verificationTokenKey)
        ..remove('verification_token')
        ..remove('token')
        ..setBool(AppSharedPrefKeys.savedLoginKey, false);
    }
    Get.offAllNamed(AppRoutesNames.loginScreen);
  }

  Future<void> contactUs() async {
    const phone = '201150588363';
    final whatsappUri = Uri.parse('whatsapp://send?phone=$phone');
    final fallbackUri = Uri.parse('https://wa.me/$phone');

    Future<bool> tryLaunch(Uri uri) async {
      try {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }

    if (await tryLaunch(whatsappUri)) return;
    if (await tryLaunch(fallbackUri)) return;

    Get.defaultDialog(
      title: AppStrings.contactUs,
      middleText: "WhatsApp: +20 115 058 8363",
      textConfirm: "OK",
      onConfirm: () => Get.back(),
    );
  }
}
