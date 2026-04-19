import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/instructor_data/instructor_data.dart';

abstract class InstructorController extends GetxController {}

/// Simple profile model — instructor endpoint returns a flat shape.
class InstructorProfile {
  final String id;
  final String name;
  final String? avatar;
  final String? title;
  final String? bio;

  InstructorProfile({
    required this.id,
    required this.name,
    this.avatar,
    this.title,
    this.bio,
  });

  factory InstructorProfile.fromJson(Map<String, dynamic> json) =>
      InstructorProfile(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        avatar: json['avatar']?.toString(),
        title: json['title']?.toString(),
        bio: json['bio']?.toString(),
      );
}

/// Trimmed course info for the instructor's course list.
class InstructorCourseItem {
  final String id;
  final String title;
  final String? thumbnail;
  final double? averageRating;
  final int totalReviews;
  final double? price;
  final double? discountPrice;
  final String? categoryName;

  InstructorCourseItem({
    required this.id,
    required this.title,
    this.thumbnail,
    this.averageRating,
    this.totalReviews = 0,
    this.price,
    this.discountPrice,
    this.categoryName,
  });

  factory InstructorCourseItem.fromJson(Map<String, dynamic> json) {
    final cat = json['category'];
    return InstructorCourseItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      categoryName: cat is Map ? cat['name']?.toString() : null,
    );
  }
}

class InstructorControllerImp extends InstructorController {
  final InstructorData _instructorData = InstructorData(Get.find());
  final MyServices _services = Get.find();

  String userToken = '';
  String instructorId = '';

  InstructorProfile? profile;
  List<InstructorCourseItem> courses = [];
  RequestStatus requestStatus = RequestStatus.loading;
  String errorMessage = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map? ?? {};
    instructorId = args['instructorId']?.toString() ??
        args['id']?.toString() ??
        '';
    // Preload profile when passed from the details screen — avoids a blank flash.
    final preload = args['profile'];
    if (preload is Map) {
      profile = InstructorProfile.fromJson(Map<String, dynamic>.from(preload));
    }
    userToken =
        _services.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            '';
    load();
  }

  Future<void> load() async {
    if (instructorId.isEmpty) {
      requestStatus = RequestStatus.failed;
      errorMessage = 'Missing instructor reference';
      update();
      return;
    }
    requestStatus = RequestStatus.loading;
    errorMessage = '';
    update();

    // Fire both requests in parallel
    final results = await Future.wait([
      _instructorData.getInstructorById(
        instructorId: instructorId,
        userToken: userToken,
      ),
      _instructorData.getInstructorCourses(
        instructorId: instructorId,
        userToken: userToken,
      ),
    ]);

    final profileResp = results[0];
    final coursesResp = results[1];

    // Profile
    if (profileResp.$1 == RequestStatus.success && profileResp.$2 is Map) {
      final raw = profileResp.$2 as Map<String, dynamic>;
      final inner = raw['data'];
      final dataMap = inner is Map && inner['data'] is Map
          ? inner['data'] as Map<String, dynamic>
          : inner is Map<String, dynamic>
              ? inner
              : null;
      if (dataMap != null) {
        profile = InstructorProfile.fromJson(dataMap);
      }
    }

    // Courses
    if (coursesResp.$1 == RequestStatus.success && coursesResp.$2 is Map) {
      final raw = coursesResp.$2 as Map<String, dynamic>;
      final inner = raw['data'];
      List<dynamic> list = [];
      if (inner is Map) {
        final deeper = inner['data'];
        if (deeper is List) list = deeper;
        // If the endpoint returned an `instructor` alongside the list, use it
        // as a secondary profile source.
        final embedded = inner['instructor'];
        if (profile == null && embedded is Map) {
          profile =
              InstructorProfile.fromJson(Map<String, dynamic>.from(embedded));
        }
      }
      courses = list
          .whereType<Map>()
          .map((m) => InstructorCourseItem.fromJson(
                Map<String, dynamic>.from(m),
              ))
          .toList();
    }

    if (profile == null && courses.isEmpty) {
      requestStatus = RequestStatus.failed;
      errorMessage = 'Could not load instructor';
    } else {
      requestStatus = RequestStatus.success;
    }
    update();
  }

  Future<void> retry() async => load();
}
