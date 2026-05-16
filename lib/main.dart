import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';
// import 'core/database/models/user_profile.dart';
// import 'core/database/models/daily_mission.dart';

import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vxmkssdgpgtaujfllbce.supabase.co',
    anonKey: 'sb_publishable_NEvvWO9tVeIpxdUl2_wl0w_H2QhRd2U',
  );

  runApp(const ProviderScope(child: MyPodoroApp()));
}

class MyPodoroApp extends ConsumerWidget {
  const MyPodoroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'MyPodoro',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoginScreen(),
    );
  }
}
