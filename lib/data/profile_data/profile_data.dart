import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class ProfileData {
  final DataRequest dataRequest;
  ProfileData(this.dataRequest);

  Future<dynamic> getProfile({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.profile,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
