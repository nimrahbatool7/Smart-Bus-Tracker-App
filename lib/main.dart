import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load environment variables from .env asset
  await Env.load();

  // 2. Initialize Supabase with credentials from .env
  await SupabaseConfig.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // 3. Start Flutter inside ProviderScope
  runApp(const ProviderScope(child: SmartBusApp()));
}

class SmartBusApp extends ConsumerWidget {
  const SmartBusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter  = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Smart Bus Tracking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: goRouter,
    );
  }
}
