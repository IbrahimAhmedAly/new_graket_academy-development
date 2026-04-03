import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class HomeData {
  DataRequest dataRequest;
  HomeData(this.dataRequest);

  getHomeData(
      {required String serial}) async {
    var response = await dataRequest.getData(
        AppApis.home,
        token: serial
    );
    return response.fold((l) => l, (r) => r);
  }
}
