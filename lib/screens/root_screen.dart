import 'package:flutter/material.dart';

import 'calendar_screen.dart';
import 'duas_screen.dart';
import 'home_screen.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    QuranScreen(),
    DuasScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: SizedBox(
        width: 66,
        height: 66,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const QiblaScreen()),
          ),
          backgroundColor: const Color(0xFFD4A843),
          foregroundColor: const Color(0xFF14323F),
          elevation: 4,
          shape: const CircleBorder(),
          tooltip: 'Qibla finder',
          child: const Text(
            'Qibla',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _NotchedNavBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
      ),
    );
  }
}

class _NotchedNavBar extends StatelessWidget {
  const _NotchedNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<(IconData, String)> _items = [
    (Icons.access_time, 'Prayers'),
    (Icons.menu_book, 'Quran'),
    (Icons.volunteer_activism, 'Duas'),
    (Icons.calendar_month, 'Calendar'),
    (Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 86 + bottomSafe,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: CustomPaint(
          painter: _NotchedBarPainter(),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomSafe),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(child: _navItem(i)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i) {
    final selected = i == currentIndex;
    final color = selected ? Colors.white : Colors.white70;
    // The centre item sits below the notch, the others are raised.
    final isCenter = i == 2;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_items[i].$1, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          _items[i].$2,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ],
    );
    return InkWell(
      onTap: () => onTap(i),
      child: Align(
        alignment: isCenter ? Alignment.bottomCenter : Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(bottom: isCenter ? 8 : 16),
          child: content,
        ),
      ),
    );
  }
}

class _NotchedBarPainter extends CustomPainter {
  const _NotchedBarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const notchRadius = 40.0;
    final guest = Rect.fromCircle(
      center: Offset(size.width / 2, 0),
      radius: notchRadius,
    );
    final path = const CircularNotchedRectangle()
        .getOuterPath(Offset.zero & size, guest);

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF7B5EA7), Color(0xFF4A7BF7), Color(0xFF22D3EE)],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NotchedBarPainter oldDelegate) => false;
}
