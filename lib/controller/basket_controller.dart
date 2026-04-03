import 'package:get/get.dart';
import 'package:new_graket_acadimy/core/class/request_status.dart';
import 'package:new_graket_acadimy/core/constants/app_strings.dart';
import 'package:new_graket_acadimy/core/services/services.dart';
import 'package:new_graket_acadimy/data/basket_data/basket_data.dart';
import 'package:new_graket_acadimy/model/basket/get_basket_model.dart';

class BasketController extends GetxController {
  final BasketData basketData = BasketData(Get.find());
  final MyServices myServices = Get.find();

  RequestStatus requestStatus = RequestStatus.loading;
  List<Map<String, dynamic>> items = [];
  int itemCount = 0;
  int basketCount = 0;
  double totalPrice = 0;
  double totalDiscountPrice = 0;
  double savings = 0;

  @override
  void onInit() {
    super.onInit();
    getBasket();
    getBasketCount();
  }

  List<Map<String, dynamic>> _normalizeList(dynamic rawList) {
    if (rawList is List) {
      return rawList
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  Future<void> getBasket() async {
    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            "";
    if (token.isEmpty) {
      requestStatus = RequestStatus.failed;
      update();
      return;
    }

    requestStatus = RequestStatus.loading;
    update();

    final response = await basketData.getBasket(token: token);
    requestStatus = response.$1;

    if (requestStatus == RequestStatus.success &&
        response.$2 is Map<String, dynamic>) {
      final raw = response.$2 as Map<String, dynamic>;
      try {
        final model = GetBasketModel.fromJson(raw);
        items = _normalizeList(model.data?.data?.items);
        itemCount = model.data?.data?.itemCount ?? items.length;
        basketCount = itemCount;
        totalPrice = (model.data?.data?.totalPrice ?? 0).toDouble();
        totalDiscountPrice =
            (model.data?.data?.totalDiscountPrice ?? 0).toDouble();
        savings = (model.data?.data?.savings ?? 0).toDouble();
      } catch (_) {
        items = [];
      }

      if (items.isEmpty) {
        final data = raw['data'];
        if (data is Map) {
          if (data['items'] is List) {
            items = _normalizeList(data['items']);
          } else if (data['data'] is Map && data['data']['items'] is List) {
            items = _normalizeList(data['data']['items']);
          }
        }
      }
    }

    if (items.isEmpty && requestStatus == RequestStatus.success) {
      requestStatus = RequestStatus.failed;
    }
    if (requestStatus != RequestStatus.success) {
      basketCount = 0;
    }

    update();
  }

  Future<void> getBasketCount() async {
    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            "";
    if (token.isEmpty) {
      basketCount = 0;
      update();
      return;
    }

    final response = await basketData.getBasketCount(token: token);
    if (response.$1 == RequestStatus.success &&
        response.$2 is Map<String, dynamic>) {
      final raw = response.$2 as Map<String, dynamic>;
      final data = raw['data'];
      if (data is Map) {
        final inner = data['data'];
        if (inner is Map && inner['count'] is num) {
          basketCount = (inner['count'] as num).toInt();
        }
      }
    }
    update();
  }

  Future<void> refreshBasket() async {
    await getBasket();
    await getBasketCount();
  }

  Future<void> removeFromBasket(String courseId) async {
    if (courseId.isEmpty) return;
    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            "";
    if (token.isEmpty) return;

    final response =
        await basketData.removeFromBasket(token: token, courseId: courseId);
    if (response.$1 == RequestStatus.success) {
      await refreshBasket();
      Get.snackbar("Basket", "Removed from basket",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Basket", "Failed to remove",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> clearBasket() async {
    final token =
        myServices.sharedPreferences.getString(AppSharedPrefKeys.userTokenKey) ??
            "";
    if (token.isEmpty) return;

    final response = await basketData.clearBasket(token: token);
    if (response.$1 == RequestStatus.success) {
      items = [];
      itemCount = 0;
      basketCount = 0;
      totalPrice = 0;
      totalDiscountPrice = 0;
      savings = 0;
      requestStatus = RequestStatus.failed;
      update();
      Get.snackbar("Basket", "Basket cleared",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar("Basket", "Failed to clear basket",
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
