import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/shared/utils/responsive.dart';

class LoadingWidget extends StatelessWidget {
  final bool useScaffold;
  final String? message;
  final bool useShimmer;
  final int shimmerItemCount;
  final double? height;

  const LoadingWidget({
    super.key,
    this.useScaffold = false,
    this.message,
    this.useShimmer = false,
    this.shimmerItemCount = 5,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (useShimmer) return _buildShimmer(context);
    final content = _buildSpinner(context);
    if (useScaffold) {
      return Scaffold(body: content);
    }
    return content;
  }

  Widget _buildSpinner(BuildContext context) {
    final res = context.responsive;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: res.dp(3.5),
            height: res.dp(3.5),
            padding: EdgeInsets.all(res.spacing(10)),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: res.spacing(12)),
            Text(
              message!,
              style: TextStyle(
                fontSize: res.fontSize(13),
                color: AppTheme.grey1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final res = context.responsive;

    final baseColor =
        isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE8ECF0);
    final highlightColor =
        isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFF5F7FA);

    return SizedBox(
      height: height,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            horizontal: res.spacing(16),
            vertical: res.spacing(8),
          ),
          itemCount: shimmerItemCount,
          itemBuilder: (_, __) => _ShimmerCard(res: res),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Responsive res;
  const _ShimmerCard({required this.res});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: res.spacing(12)),
      padding: EdgeInsets.all(res.spacing(14)),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: res.dp(2.4),
                height: res.dp(2.4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: res.spacing(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: res.dp(0.8),
                      width: res.wp(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: res.spacing(5)),
                    Container(
                      height: res.dp(0.6),
                      width: res.wp(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: res.dp(1.2),
                width: res.wp(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          SizedBox(height: res.spacing(10)),
          Container(
            height: res.dp(0.55),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: res.spacing(5)),
          Container(
            height: res.dp(0.55),
            width: res.wp(55),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
