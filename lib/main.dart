import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/security/screen_security_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121638),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Enable screen security on app start
  try {
    await ScreenSecurityService.enableProtection();
  } catch (_) {
    // Security service may not be available in debug mode
  }

  runApp(const MuzakratyApp());
}

class MuzakratyApp extends StatelessWidget {
  const MuzakratyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatus())),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MaterialApp.router(
          title: 'مذاكرتي',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
