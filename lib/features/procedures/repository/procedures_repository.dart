import 'package:sw1_p1/core/api/api_client.dart';
import 'package:sw1_p1/features/procedures/entities/procedure_models.dart';

class ProceduresRepository {
  // ===== Políticas disponibles para mobile =====
  Future<List<WorkflowPolicy>> getAvailablePolicies(
    String organizationId,
  ) async {
    final response = await ApiClient.instance.dio.get(
      '/mobile/workflow-policies/available',
      queryParameters: {'organizationId': organizationId},
    );
    final list = response.data as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map(WorkflowPolicy.fromJson)
        .toList();
  }

  // ===== Mis trámites =====
  Future<PageResponse<ProcedureSummary>> getMyProcedures({
    int page = 0,
    int size = 20,
  }) async {
    final response = await ApiClient.instance.dio.get(
      '/mobile/procedures/my',
      queryParameters: {'page': page, 'size': size},
    );
    if (response.data is List) {
      // Si el backend devuelve lista sin paginación
      final items =
          (response.data as List)
              .whereType<Map<String, dynamic>>()
              .map(ProcedureSummary.fromJson)
              .toList();
      return PageResponse<ProcedureSummary>(
        content: items,
        totalElements: items.length,
        totalPages: 1,
        number: 0,
        size: items.length,
      );
    }
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      ProcedureSummary.fromJson,
    );
  }

  // ===== Detalle =====
  Future<ProcedureDetail> getProcedureById(String id) async {
    final response = await ApiClient.instance.dio.get('/mobile/procedures/$id');
    return ProcedureDetail.fromJson(response.data as Map<String, dynamic>);
  }

  // ===== Historial =====
  Future<List<ProcedureHistoryEntry>> getProcedureHistory(String id) async {
    final response = await ApiClient.instance.dio.get(
      '/mobile/procedures/$id/history',
    );
    final list = response.data as List;
    return list
        .whereType<Map<String, dynamic>>()
        .map(ProcedureHistoryEntry.fromJson)
        .toList();
  }

  // ===== Iniciar trámite =====
  Future<ProcedureDetail> startProcedure(StartProcedureRequest req) async {
    final response = await ApiClient.instance.dio.post(
      '/mobile/procedures',
      data: req.toJson(),
    );
    return ProcedureDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
