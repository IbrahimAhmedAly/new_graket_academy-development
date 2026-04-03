
import '../../../core/class/data_request.dart';
import '../../../core/constants/app_apis.dart';


class LoginData {
  DataRequest dataRequest;
  LoginData(this.dataRequest);

  postLoginData({required String email,required String password ,required String serial}) async {
    var response = await dataRequest.postDataJsonBody(AppApis.login,
        {
      "email": email,
      "password": password,
      "serial": serial
    },
     token: null
    );

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
