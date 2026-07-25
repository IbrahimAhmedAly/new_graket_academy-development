import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class BannersData {
  final DataRequest dataRequest;
  BannersData(this.dataRequest);

  Future<dynamic> getBanners({String? token}) async {
    final response = await dataRequest.getData(
      AppApis.getBanners,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
