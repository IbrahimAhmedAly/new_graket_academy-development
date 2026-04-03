import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class BasketData {
  final DataRequest dataRequest;
  BasketData(this.dataRequest);

  Future<dynamic> getBasket({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.getBasket,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getBasketCount({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.getBasketCount,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> addToBasket({
    required String token,
    required String courseId,
  }) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.addBasket,
      {"courseId": courseId},
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> removeFromBasket({
    required String token,
    required String courseId,
  }) async {
    final response = await dataRequest.deleteData(
      AppApis.removeFromBasket(courseId),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> clearBasket({required String token}) async {
    final response = await dataRequest.deleteData(
      AppApis.deleteBasket,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
