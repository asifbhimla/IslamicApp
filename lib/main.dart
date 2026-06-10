import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/root_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.load();
  await NotificationService.init();
  await NotificationService.requestPermissions();
  await NotificationService.rescheduleAthanNotifications(appState);

  runApp(IslamicApp(appState: appState));
}

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        title: 'Islamic App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00695C),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const RootScreen(),
      ),
    );
  }
}
