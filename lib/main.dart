import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/di.dart' as di;
import 'core/network/supabase_client.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  await SupabaseService.init(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router;
    return MaterialApp.router(
      routerConfig: router,
      title: 'BundaCare',
      theme: ThemeData.dark(),
    );
  }
}
