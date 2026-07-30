import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

/// Data source for the public legal documents (privacy policy & terms).
class PolicyData {
  final DataRequest dataRequest;
  PolicyData(this.dataRequest);

  Future<dynamic> getPrivacy({String? token, String lang = 'en'}) async {
    final response = await dataRequest.getData(
      AppApis.privacy,
      token: token,
      queryParameters: {'lang': lang},
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getTerms({String? token, String lang = 'en'}) async {
    final response = await dataRequest.getData(
      AppApis.terms,
      token: token,
      queryParameters: {'lang': lang},
    );
    return response.fold((l) => l, (r) => r);
  }
}
