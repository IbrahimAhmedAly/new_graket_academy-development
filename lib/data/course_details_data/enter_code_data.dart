
import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class EnterCodeData {
  DataRequest dataRequest;
  EnterCodeData(this.dataRequest);

  postCourseCode({required String code ,required userToken}) async {
    var response = await dataRequest.postDataJsonBody(
        AppApis.redeemVerificationCode,
        {"code": code},
        token: userToken
    );

    return response.fold((l) => l, (r) => r);
  }
}