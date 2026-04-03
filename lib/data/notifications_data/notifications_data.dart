import '../../core/class/data_request.dart';
import '../../core/constants/app_apis.dart';

class NotificationsData {
  final DataRequest dataRequest;
  NotificationsData(this.dataRequest);

  Future<dynamic> getNotifications({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.getNotifications,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getNotificationsGrouped({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.getNotificationsGrouped,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getUnreadCount({required String token}) async {
    final response = await dataRequest.getData(
      AppApis.getUnreadCount,
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
