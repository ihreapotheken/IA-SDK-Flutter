import 'package:appsdk_v2_flutter_plugin_example/src/views/cardlink_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/home_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/screens_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/services_view.dart';
import 'package:flutter/material.dart';

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  int _selectedTabIndex = 0;

  static const _navigationItems = <({String label, IconData icon})>[
    (label: 'Host App', icon: Icons.home),
    (label: 'CardLink', icon: Icons.nfc),
    (label: 'Services', icon: Icons.category),
    (label: 'Screens', icon: Icons.screenshot),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: _buildCurrentView(),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    return switch (_selectedTabIndex) {
      0 => const HomeView(),
      1 => const CardLinkView(),
      2 => const ServicesView(),
      3 => const ScreensView(),
      _ => throw UnimplementedError(
          'Tab view not defined for index #$_selectedTabIndex.',
        ),
    };
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: BorderSide())),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Row(
          children: [
            for (final (index, item) in _navigationItems.indexed)
              Expanded(
                child: _NavigationButton(
                  label: item.label,
                  icon: item.icon,
                  isSelected: _selectedTabIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Theme.of(context).primaryColor : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
