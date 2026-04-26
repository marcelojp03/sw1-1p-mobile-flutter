import 'package:intl/intl.dart';

class NotificationResponse {
  final String id;
  final String title;
  final String? body;
  final String? type;
  final bool read;
  final String? createdAt;
  final String? procedureId;

  const NotificationResponse({
    required this.id,
    required this.title,
    this.body,
    this.type,
    required this.read,
    this.createdAt,
    this.procedureId,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        id: json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? json['message'] as String?,
        type: json['type'] as String?,
        read: json['read'] as bool? ?? false,
        createdAt: json['createdAt'] as String?,
        procedureId: json['procedureId']?.toString(),
      );

  String get formattedDate {
    if (createdAt == null) return '';
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Ahora mismo';
      if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return createdAt!;
    }
  }

  NotificationResponse copyWith({bool? read}) => NotificationResponse(
    id: id,
    title: title,
    body: body,
    type: type,
    read: read ?? this.read,
    createdAt: createdAt,
    procedureId: procedureId,
  );
}
