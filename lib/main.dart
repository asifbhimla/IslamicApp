import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'screens/root_screen.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final appState = AppState();
  final deviceLocale = ui.PlatformDispatcher.instance.locale;
  appState.deviceLocale = deviceLocale.countryCode == null
      ? deviceLocale.languageCode
      : '${deviceLocale.languageCode}_${deviceLocale.countryCode}';
  await appState.load();

  // Use the phone's current location as the default, unless the user has
  // explicitly chosen one. Runs in the background so it never blocks startup;
  // if permission is denied the existing saved/Makkah default is kept.
  unawaited(_autoDetectLocation(appState));

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

Future<void> _autoDetectLocation(AppState appState) async {
  if (appState.locationExplicitlySet) return;
  try {
    final position = await LocationService.getCurrentPosition();
    if (position == null) return; // permission denied / services off
    await appState.setLocation(
      position.latitude,
      position.longitude,
      'Current location',
      explicit: false,
    );
    await NotificationService.rescheduleAthanNotifications(appState);
  } catch (_) {
    // Keep the existing default on any failure.
  }
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
