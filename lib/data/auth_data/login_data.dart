import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class LoginData {
  DataRequest dataRequest;
  LoginData(this.dataRequest);

  postLoginData({
    required String email,
    required String password,
    required String serial,
  }) async {
    var response = await dataRequest.postDataJsonBody(AppApis.login, {
      "email": email,
      "password": password,
      "serial": serial,
    }, token: null);

    return response.fold((l) => l, (r) => r);
  }

  /// POST /auth/change-password — requires the logged-in user's access token.
  /// The session stays valid afterwards, so the caller must NOT clear tokens.
  changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    var response = await dataRequest.postDataJsonBody(AppApis.changePassword, {
      "currentPassword": currentPassword,
      "newPassword": newPassword,
      "confirmPassword": confirmPassword,
    }, token: token);

    return response.fold((l) => l, (r) => r);
  }

  // postLoginWithGoogleData(String email, String username, String password,
  //     String userGooglePhoto, String phoneNumber) async {
  //   var response = await dataRequest.postData(AppApis.loginWithGoogle, {
  //     "email": email,
  //     "username": username,
  //     "password": password,
  //     "userGoogleImage": userGooglePhoto,
  //     "phonenumber": phoneNumber,
  //   });
  //   return response.fold((l) => l, (r) => r);
  // }
}
