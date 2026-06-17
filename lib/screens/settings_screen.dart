import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _locating = false;

  Future<void> _updateLocation() async {
    setState(() => _locating = true);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final position = await LocationService.getCurrentPosition();
    if (!mounted) return;
    setState(() => _locating = false);

    if (position == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text(
            'Could not get location. Check that location services and permission are enabled.'),
      ));
      return;
    }
    await state.setLocation(
      position.latitude,
      position.longitude,
      'Lat ${position.latitude.toStringAsFixed(3)}, '
      'Lng ${position.longitude.toStringAsFixed(3)}',
    );
    await NotificationService.rescheduleAthanNotifications(state);
    messenger.showSnackBar(
        const SnackBar(content: Text('Location updated.')));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: ListView(
        padding: EdgeInsets.only(top: kToolbarHeight + MediaQuery.of(context).padding.top),
        children: [
          const _SectionHeader('Location'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Current location'),
              subtitle: Text(state.locationLabel),
              trailing: _locating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              onTap: _locating ? null : _updateLocation,
            ),
          ),
          const _SectionHeader('Prayer times'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calculate),
                  title: const Text('Calculation method'),
                  subtitle: Text(state.calculationMethod.label),
                  onTap: () => _pickCalculationMethod(context, state),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Asr calculation (madhab)'),
                  subtitle: Text(
                      state.madhab == Madhab.hanafi ? 'Hanafi (later Asr)' : 'Shafi, Maliki, Hanbali (standard)'),
                  onTap: () => _pickMadhab(context, state),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active),
                  title: const Text('Athan notifications'),
                  subtitle: const Text('Notify at each prayer time'),
                  value: state.athanNotificationsEnabled,
                  onChanged: (value) async {
                    await state.setAthanNotificationsEnabled(value);
                    if (value) await NotificationService.requestPermissions();
                    await NotificationService.rescheduleAthanNotifications(state);
                  },
                ),
              ],
            ),
          ),
          const _SectionHeader('Quran'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              leading: const Icon(Icons.format_size),
              title: const Text('Arabic text size'),
              subtitle: Slider(
                min: 18,
                max: 40,
                divisions: 11,
                value: state.quranArabicFontSize,
                label: state.quranArabicFontSize.round().toString(),
                onChanged: (value) => state.setQuranArabicFontSize(value),
              ),
            ),
          ),
          const _SectionHeader('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('QalbCare'),
              subtitle: Text(
                  'Prayer times are calculated locally on your device using the '
                  'selected method. Quran text and translation (Saheeh '
                  'International) are bundled and work fully offline.'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      ),
    );
  }

  Future<void> _pickCalculationMethod(
      BuildContext context, AppState state) async {
    final key = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Calculation method'),
        children: [
          RadioGroup<String>(
            groupValue: state.calculationMethodKey,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final method in calculationMethods)
                  RadioListTile<String>(
                    title: Text(method.label),
                    value: method.key,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (key == null) return;
    await state.setCalculationMethod(key);
    await NotificationService.rescheduleAthanNotifications(state);
  }

  Future<void> _pickMadhab(BuildContext context, AppState state) async {
    final madhab = await showDialog<Madhab>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Asr calculation'),
        children: [
          RadioGroup<Madhab>(
            groupValue: state.madhab,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<Madhab>(
                  title: Text('Shafi, Maliki, Hanbali (standard)'),
                  value: Madhab.shafi,
                ),
                RadioListTile<Madhab>(
                  title: Text('Hanafi (later Asr)'),
                  value: Madhab.hanafi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (madhab == null) return;
    await state.setMadhab(madhab);
    await NotificationService.rescheduleAthanNotifications(state);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}
