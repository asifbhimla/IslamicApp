import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/root_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appState = AppState();
  await appState.load();
  try {
    await NotificationService.init();
    await NotificationService.requestPermissions();
    await NotificationService.rescheduleAthanNotifications(appState);
  } catch (e, stack) {
    // The app is fully usable without notifications; never block startup.
    FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stack));
  }

  runApp(QalbCareApp(appState: appState));
}

class QalbCareApp extends StatelessWidget {
  const QalbCareApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        title: 'QalbCare',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B5EA7)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7B5EA7),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const RootScreen(),
      ),
    );
  }
}
