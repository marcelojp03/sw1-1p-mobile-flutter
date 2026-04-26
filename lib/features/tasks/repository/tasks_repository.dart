import 'package:dio/dio.dart';
import 'package:sw1_p1/core/api/api_client.dart';
import 'package:sw1_p1/features/procedures/entities/procedure_models.dart';
import 'package:sw1_p1/features/tasks/entities/task_models.dart';

class TasksRepository {
  Dio get _dio => ApiClient.instance.dio;

  /// GET /mobile/tasks/my
  Future<PageResponse<TaskResponse>> getMyTasks({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        '/mobile/tasks/my',
        queryParameters: {'page': page, 'size': size},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('content')) {
        return PageResponse<TaskResponse>.fromJson(
          data,
          (json) => TaskResponse.fromJson(json),
        );
      }
      if (data is List) {
        final items =
            data
                .whereType<Map<String, dynamic>>()
                .map(TaskResponse.fromJson)
                .toList();
        return PageResponse<TaskResponse>(
          content: items,
          totalElements: items.length,
          totalPages: 1,
          number: 0,
          size: items.length,
        );
      }
      return PageResponse<TaskResponse>(
        content: [],
        totalElements: 0,
        totalPages: 0,
        number: 0,
        size: size,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ?? 'Error al obtener tareas',
      );
    }
  }

  /// GET /mobile/tasks/{id}
  Future<TaskResponse> getTaskById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/tasks/$id',
      );
      return TaskResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ?? 'Error al obtener la tarea',
      );
    }
  }

  /// POST /mobile/tasks/{id}/complete
  Future<TaskResponse> completeTask(
    String id,
    Map<String, dynamic> formResponse, {
    String? notes,
  }) async {
    try {
      final body =
          CompleteTaskRequest(
            formResponse: formResponse,
            notes: notes,
          ).toJson();
      final response = await _dio.post<Map<String, dynamic>>(
        '/mobile/tasks/$id/complete',
        data: body,
      );
      return TaskResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'Error al completar la tarea',
      );
    }
  }

  /// POST /mobile/tasks/{id}/attachments  (multipart/form-data, field "files")
  Future<TaskResponse> uploadAttachments(
    String id,
    List<MultipartFile> files,
  ) async {
    try {
      final formData = FormData.fromMap({'files': files});
      final response = await _dio.post<Map<String, dynamic>>(
        '/mobile/tasks/$id/attachments',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return TaskResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ?? 'Error al subir archivos',
      );
    }
  }
}
