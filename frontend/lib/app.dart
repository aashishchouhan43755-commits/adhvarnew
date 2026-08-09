import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_router.dart';
import 'theme/theme.dart';

class AdhvarApp extends ConsumerWidget {
  const AdhvarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Adhvar',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
