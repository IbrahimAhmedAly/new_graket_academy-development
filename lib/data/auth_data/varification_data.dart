import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class VarificationData {
  DataRequest dataRequest;
  VarificationData(this.dataRequest);

  postVarificationCode(
      {required String verificationToken, required String code}) async {
    var response = await dataRequest.postDataJsonBody(
        AppApis.emailVerification, {"code": code, "verificationToken": verificationToken},
        token: verificationToken);

    return response.fold((l) => l, (r) => r);
  }
}
