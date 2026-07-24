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

  Future<dynamic> markAsRead({
    required String id,
    required String token,
  }) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.markAsRead(id),
      {},
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> markAllAsRead({required String token}) async {
    final response = await dataRequest.postDataJsonBody(
      AppApis.markAllAsRead,
      {},
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> deleteNotification({
    required String id,
    required String token,
  }) async {
    final response = await dataRequest.deleteData(
      AppApis.deleteNotification(id),
      token: token,
    );
    return response.fold((l) => l, (r) => r);
  }
}
