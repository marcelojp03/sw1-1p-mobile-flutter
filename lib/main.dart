import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw1_p1/config/environment.dart';
import 'package:sw1_p1/config/router/router.dart';
import 'package:sw1_p1/config/theme/app_theme.dart';
import 'package:sw1_p1/config/theme/theme_provider.dart';
import 'package:sw1_p1/core/api/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  ApiClient.instance.init();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeNotifierProvider);
    return MaterialApp.router(
      title: 'SW1 Workflow',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
