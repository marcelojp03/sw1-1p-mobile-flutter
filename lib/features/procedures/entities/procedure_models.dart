import 'package:intl/intl.dart';

// ===== Política de workflow disponible =====
class WorkflowPolicy {
  final String id;
  final String policyKey;
  final String name;
  final String? description;
  final String version;
  final List<String> allowedStartChannels;

  const WorkflowPolicy({
    required this.id,
    required this.policyKey,
    required this.name,
    this.description,
    required this.version,
    required this.allowedStartChannels,
  });

  factory WorkflowPolicy.fromJson(Map<String, dynamic> json) => WorkflowPolicy(
    id: json['id']?.toString() ?? '',
    policyKey: json['policyKey'] as String? ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    version: json['version']?.toString() ?? '',
    allowedStartChannels: List<String>.from(json['allowedStartChannels'] ?? []),
  );

  bool get mobileAllowed => allowedStartChannels.contains('MOBILE');
}

// ===== Inicio de trámite =====
class StartProcedureRequest {
  final String policyId;
  final String clientId;
  final String organizationId;
  final Map<String, dynamic>? initialFormData;

  const StartProcedureRequest({
    required this.policyId,
    required this.clientId,
    required this.organizationId,
    this.initialFormData,
  });

  Map<String, dynamic> toJson() => {
    'policyId': policyId,
    'clientId': clientId,
    'organizationId': organizationId,
    if (initialFormData != null) 'initialFormData': initialFormData,
  };
}

// ===== Resumen de trámite (lista) =====
class ProcedureSummary {
  final String id;
  final String status;
  final String? policyName;
  final String? currentStepName;
  final String? createdAt;

  const ProcedureSummary({
    required this.id,
    required this.status,
    this.policyName,
    this.currentStepName,
    this.createdAt,
  });

  factory ProcedureSummary.fromJson(Map<String, dynamic> json) =>
      ProcedureSummary(
        id: json['id']?.toString() ?? '',
        status: json['status'] as String? ?? 'CREATED',
        policyName: json['policyName'] as String?,
        currentStepName: json['currentStepName'] as String?,
        createdAt: json['createdAt'] as String?,
      );

  String get formattedDate {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }
}

// ===== Detalle de trámite =====
class ProcedureDetail {
  final String id;
  final String status;
  final String? policyName;
  final String? policyKey;
  final String? currentStepName;
  final String? createdAt;
  final String? updatedAt;
  final String? clientId;
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic>? formData;

  const ProcedureDetail({
    required this.id,
    required this.status,
    this.policyName,
    this.policyKey,
    this.currentStepName,
    this.createdAt,
    this.updatedAt,
    this.clientId,
    this.tasks = const [],
    this.formData,
  });

  factory ProcedureDetail.fromJson(Map<String, dynamic> json) =>
      ProcedureDetail(
        id: json['id']?.toString() ?? '',
        status: json['status'] as String? ?? 'CREATED',
        policyName: json['policyName'] as String?,
        policyKey: json['policyKey'] as String?,
        currentStepName: json['currentStepName'] as String?,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
        clientId: json['clientId']?.toString(),
        tasks: List<Map<String, dynamic>>.from(json['tasks'] ?? []),
        formData:
            json['formData'] is Map
                ? Map<String, dynamic>.from(json['formData'] as Map)
                : null,
      );

  String get formattedDate {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }
}

// ===== Historial =====
class ProcedureHistoryEntry {
  final String id;
  final String eventType;
  final String? description;
  final String? createdAt;
  final String? createdBy;

  const ProcedureHistoryEntry({
    required this.id,
    required this.eventType,
    this.description,
    this.createdAt,
    this.createdBy,
  });

  factory ProcedureHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ProcedureHistoryEntry(
        id: json['id']?.toString() ?? '',
        eventType: json['eventType'] as String? ?? '',
        description: json['description'] as String?,
        createdAt: json['createdAt'] as String?,
        createdBy: json['createdBy'] as String?,
      );

  String get formattedDate {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }
}

// ===== Página genérica =====
class PageResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number;
  final int size;

  const PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    List<Map<String, dynamic>> contentList = [];
    if (json['content'] is List) {
      contentList =
          (json['content'] as List).whereType<Map<String, dynamic>>().toList();
    }
    return PageResponse<T>(
      content: contentList.map(fromJson).toList(),
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
      number: json['number'] as int? ?? 0,
      size: json['size'] as int? ?? 20,
    );
  }
}
