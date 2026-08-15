import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class ProfileData {
  final DataRequest dataRequest;
  ProfileData(this.dataRequest);

  /// The signed-in user's own record.
  /// GET /user/me — replaces the old `/user` call, which was never registered
  /// on the backend and silently 404'd.
  Future<dynamic> getMe({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.getMe,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// Partial update of the signed-in user.
  /// PATCH /user/me — [body] must carry only the fields that actually changed
  /// and must never be empty.
  Future<dynamic> updateMe({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final response = await dataRequest.patchDataJsonBody(
      AppApis.updateMe,
      body,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
