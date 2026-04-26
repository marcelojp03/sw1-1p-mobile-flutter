import 'package:dio/dio.dart';
import 'package:sw1_p1/core/api/api_client.dart';
import 'package:sw1_p1/features/notifications/entities/notification_models.dart';
import 'package:sw1_p1/features/procedures/entities/procedure_models.dart';

class NotificationsRepository {
  Dio get _dio => ApiClient.instance.dio;

  Future<PageResponse<NotificationResponse>> getNotifications({
    bool? unreadOnly,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};
      if (unreadOnly == true) queryParams['unreadOnly'] = true;

      final response = await _dio.get<dynamic>(
        '/mobile/notifications',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('content')) {
        return PageResponse<NotificationResponse>.fromJson(
          data,
          (json) => NotificationResponse.fromJson(json),
        );
      }
      if (data is List) {
        final items =
            data
                .whereType<Map<String, dynamic>>()
                .map(NotificationResponse.fromJson)
                .toList();
        return PageResponse<NotificationResponse>(
          content: items,
          totalElements: items.length,
          totalPages: 1,
          number: 0,
          size: items.length,
        );
      }
      return PageResponse<NotificationResponse>(
        content: [],
        totalElements: 0,
        totalPages: 0,
        number: 0,
        size: size,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'Error al obtener notificaciones',
      );
    }
  }

  Future<NotificationResponse> markAsRead(String id) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/mobile/notifications/$id/read',
      );
      return NotificationResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'Error al marcar como leída',
      );
    }
  }
}
