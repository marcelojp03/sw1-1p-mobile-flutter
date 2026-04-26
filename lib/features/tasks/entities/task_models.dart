import 'package:intl/intl.dart';

// ===== Attachment ref =====
class AttachmentRef {
  final String fileName;
  final String storageKey;
  final String? mimeType;
  final int? sizeBytes;
  final String? uploadedAt;
  final String? uploadedBy;

  const AttachmentRef({
    required this.fileName,
    required this.storageKey,
    this.mimeType,
    this.sizeBytes,
    this.uploadedAt,
    this.uploadedBy,
  });

  factory AttachmentRef.fromJson(Map<String, dynamic> json) => AttachmentRef(
    fileName: json['fileName'] as String? ?? '',
    storageKey: json['storageKey'] as String? ?? '',
    mimeType: json['mimeType'] as String?,
    sizeBytes: json['sizeBytes'] as int?,
    uploadedAt: json['uploadedAt'] as String?,
    uploadedBy: json['uploadedBy'] as String?,
  );

  String get formattedDate {
    if (uploadedAt == null) return '';
    try {
      final dt = DateTime.parse(uploadedAt!).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return uploadedAt!;
    }
  }
}

// ===== Form field descriptor =====
class FormFieldDescriptor {
  final String name;
  final String type; // TEXT, NUMBER, DATE, BOOLEAN, FILE, SELECT, TEXTAREA
  final String? label;
  final bool required;
  final String? placeholder;
  final List<String>? options; // for SELECT
  final dynamic defaultValue;

  const FormFieldDescriptor({
    required this.name,
    required this.type,
    this.label,
    this.required = false,
    this.placeholder,
    this.options,
    this.defaultValue,
  });

  factory FormFieldDescriptor.fromJson(Map<String, dynamic> json) =>
      FormFieldDescriptor(
        name: json['name'] as String? ?? '',
        type: (json['type'] as String? ?? 'TEXT').toUpperCase(),
        label: json['label'] as String?,
        required: json['required'] as bool? ?? false,
        placeholder: json['placeholder'] as String?,
        options:
            json['options'] is List
                ? List<String>.from(json['options'] as List)
                : null,
        defaultValue: json['defaultValue'],
      );
}

// ===== Task response =====
class TaskResponse {
  final String id;
  final String status;
  final String? stepName;
  final String? title;
  final String? description;
  final String? taskAudience;
  final String? procedureId;
  final String? assignedClientId;
  final Map<String, dynamic>? form;
  final Map<String, dynamic>? formResponse;
  final List<AttachmentRef> attachments;
  final String? createdAt;
  final String? updatedAt;

  const TaskResponse({
    required this.id,
    required this.status,
    this.stepName,
    this.title,
    this.description,
    this.taskAudience,
    this.procedureId,
    this.assignedClientId,
    this.form,
    this.formResponse,
    this.attachments = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    List<AttachmentRef> attachmentList = [];
    if (json['attachments'] is List) {
      attachmentList =
          (json['attachments'] as List)
              .whereType<Map<String, dynamic>>()
              .map(AttachmentRef.fromJson)
              .toList();
    }

    return TaskResponse(
      id: json['id']?.toString() ?? '',
      status: json['status'] as String? ?? 'PENDING',
      stepName: json['stepName'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      taskAudience: json['taskAudience'] as String?,
      procedureId: json['procedureId']?.toString(),
      assignedClientId: json['assignedClientId']?.toString(),
      form:
          json['form'] is Map
              ? Map<String, dynamic>.from(json['form'] as Map)
              : null,
      formResponse:
          json['formResponse'] is Map
              ? Map<String, dynamic>.from(json['formResponse'] as Map)
              : null,
      attachments: attachmentList,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  List<FormFieldDescriptor> get formFields {
    final fieldsRaw = form?['fields'];
    if (fieldsRaw is! List) return [];
    return fieldsRaw
        .whereType<Map<String, dynamic>>()
        .map(FormFieldDescriptor.fromJson)
        .toList();
  }

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

// ===== Complete task request =====
class CompleteTaskRequest {
  final Map<String, dynamic> formResponse;
  final String? notes;

  const CompleteTaskRequest({required this.formResponse, this.notes});

  Map<String, dynamic> toJson() => {
    'formResponse': formResponse,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };
}
