import '../../../core/class/data_request.dart';
import '../../../core/constants/app_apis.dart';


class SignUpData {
  DataRequest dataRequest;
  SignUpData(this.dataRequest);

  postSignUpData(
      {required String email,
      required String displayedName,
      required String password,
      required String serial}) async {
    var response = await dataRequest.postDataJsonBody(
        AppApis.register,
        {
          "email": email,
          "password": password,
          "name": displayedName,
          "serial": serial
        },
        token: null);

    return response.fold((l) => l, (r) => r);
  }
}
