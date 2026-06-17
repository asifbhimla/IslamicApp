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
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.place),
                  title: const Text('Current location'),
                  subtitle: Text(state.locationLabel),
                ),
                ListTile(
                  leading: const Icon(Icons.location_city),
                  title: const Text('Select city'),
                  subtitle: const Text('Choose from a list of cities'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickCity(context, state),
                ),
                ListTile(
                  leading: const Icon(Icons.my_location),
                  title: const Text('Use GPS location'),
                  subtitle: const Text('Detect automatically'),
                  trailing: _locating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _locating ? null : _updateLocation,
                ),
              ],
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

  Future<void> _pickCity(BuildContext context, AppState state) async {
    final city = await Navigator.of(context).push<_City>(
      MaterialPageRoute(builder: (_) => const _CityPickerScreen()),
    );
    if (city == null || !mounted) return;
    await state.setLocation(city.lat, city.lng, city.label);
    await NotificationService.rescheduleAthanNotifications(state);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location set to ${city.label}')),
      );
    }
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

class _City {
  const _City(this.label, this.lat, this.lng);
  final String label;
  final double lat;
  final double lng;
}

const _cities = <_City>[
  _City('Makkah, Saudi Arabia', 21.4225, 39.8262),
  _City('Madinah, Saudi Arabia', 24.4686, 39.6142),
  _City('Riyadh, Saudi Arabia', 24.7136, 46.6753),
  _City('Jeddah, Saudi Arabia', 21.5433, 39.1728),
  _City('Dubai, UAE', 25.2048, 55.2708),
  _City('Abu Dhabi, UAE', 24.4539, 54.3773),
  _City('Doha, Qatar', 25.2854, 51.5310),
  _City('Kuwait City, Kuwait', 29.3759, 47.9774),
  _City('Manama, Bahrain', 26.2285, 50.5860),
  _City('Muscat, Oman', 23.5880, 58.3829),
  _City('Cairo, Egypt', 30.0444, 31.2357),
  _City('Istanbul, Turkey', 41.0082, 28.9784),
  _City('Ankara, Turkey', 39.9334, 32.8597),
  _City('Islamabad, Pakistan', 33.6844, 73.0479),
  _City('Karachi, Pakistan', 24.8607, 67.0011),
  _City('Lahore, Pakistan', 31.5204, 74.3587),
  _City('Dhaka, Bangladesh', 23.8103, 90.4125),
  _City('Jakarta, Indonesia', -6.2088, 106.8456),
  _City('Kuala Lumpur, Malaysia', 3.1390, 101.6869),
  _City('London, UK', 51.5074, -0.1278),
  _City('Birmingham, UK', 52.4862, -1.8904),
  _City('Paris, France', 48.8566, 2.3522),
  _City('Berlin, Germany', 52.5200, 13.4050),
  _City('New York, USA', 40.7128, -74.0060),
  _City('Los Angeles, USA', 34.0522, -118.2437),
  _City('Chicago, USA', 41.8781, -87.6298),
  _City('Houston, USA', 29.7604, -95.3698),
  _City('Toronto, Canada', 43.6532, -79.3832),
  _City('Sydney, Australia', -33.8688, 151.2093),
  _City('Melbourne, Australia', -37.8136, 144.9631),
  _City('Johannesburg, South Africa', -26.2041, 28.0473),
  _City('Nairobi, Kenya', -1.2921, 36.8219),
  _City('Lagos, Nigeria', 6.5244, 3.3792),
  _City('Casablanca, Morocco', 33.5731, -7.5898),
  _City('Tunis, Tunisia', 36.8065, 10.1815),
  _City('Amman, Jordan', 31.9454, 35.9284),
  _City('Beirut, Lebanon', 33.8938, 35.5018),
  _City('Baghdad, Iraq', 33.3152, 44.3661),
  _City('Tehran, Iran', 35.6892, 51.3890),
  _City('Kabul, Afghanistan', 34.5553, 69.2075),
];

class _CityPickerScreen extends StatefulWidget {
  const _CityPickerScreen();

  @override
  State<_CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<_CityPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _cities.where((c) {
      if (_query.isEmpty) return true;
      return c.label.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select City')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search city',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final city = filtered[index];
                return ListTile(
                  leading: const Icon(Icons.location_city),
                  title: Text(city.label),
                  onTap: () => Navigator.of(context).pop(city),
                );
              },
            ),
          ),
        ],
      ),
    );
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
