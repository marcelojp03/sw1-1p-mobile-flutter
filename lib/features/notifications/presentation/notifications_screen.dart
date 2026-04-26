import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/features/notifications/entities/notification_models.dart';
import 'package:sw1_p1/features/notifications/providers/notifications_provider.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';
import 'package:sw1_p1/shared/widgets/loading_widget.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadCountProvider);
        },
        child: notificationsAsync.when(
          loading:
              () => const LoadingWidget(useShimmer: true, shimmerItemCount: 6),
          error:
              (e, _) => Center(
                child: Text(
                  'Error: ${e.toString().replaceFirst('Exception: ', '')}',
                ),
              ),
          data: (page) {
            if (page.content.isEmpty) {
              return _buildEmpty(context);
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive.spacing(12),
                vertical: context.responsive.spacing(8),
              ),
              itemCount: page.content.length,
              itemBuilder: (_, i) {
                final n = page.content[i];
                return _NotificationTile(
                  notification: n,
                  onTap: () => _handleTap(context, ref, n),
                ).animate().fadeIn(
                  delay: Duration(milliseconds: i * 40),
                  duration: 280.ms,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, NotificationResponse n) {
    if (!n.read) {
      ref.read(markReadProvider.notifier).markRead(n.id);
    }
    if ((n.procedureId ?? '').isNotEmpty) {
      context.push('/tramites/${n.procedureId}');
    }
  }

  Widget _buildEmpty(BuildContext context) {
    final res = context.responsive;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: res.dp(5),
            color: AppTheme.grey1,
          ),
          SizedBox(height: res.spacing(12)),
          Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: res.fontSize(16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationResponse notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final res = context.responsive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnread = !notification.read;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: res.spacing(8)),
        padding: EdgeInsets.all(res.spacing(14)),
        decoration: BoxDecoration(
          color:
              isUnread
                  ? AppTheme.primaryColor.withValues(alpha: 0.06)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isUnread
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05)),
          ),
          boxShadow:
              isUnread
                  ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(res.spacing(8)),
              decoration: BoxDecoration(
                color: (isUnread ? AppTheme.primaryColor : AppTheme.grey1)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUnread
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_none_rounded,
                color: isUnread ? AppTheme.primaryColor : AppTheme.grey1,
                size: res.iconSize(18),
              ),
            ),
            SizedBox(width: res.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                      fontSize: res.fontSize(13),
                    ),
                  ),
                  if ((notification.body ?? '').isNotEmpty) ...[
                    SizedBox(height: res.spacing(3)),
                    Text(
                      notification.body!,
                      style: TextStyle(
                        fontSize: res.fontSize(12),
                        color: AppTheme.grey1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: res.spacing(4)),
                  Text(
                    notification.formattedDate,
                    style: TextStyle(
                      fontSize: res.fontSize(10),
                      color: AppTheme.grey1,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: res.dp(0.4),
                height: res.dp(0.4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
