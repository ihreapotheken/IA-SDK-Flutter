import 'package:ia_example_single_entry_point/src/components/tab_page.dart';
import 'package:ia_example_single_entry_point/src/ia_sdk_page.dart';
import 'package:flutter/material.dart';

class SingleEntryPointApp extends StatelessWidget {
  const SingleEntryPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IA SDK Single Entry Point',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.green),
      ),
      home: const MainTabsView(),
    );
  }
}

class MainTabsView extends StatefulWidget {
  const MainTabsView({super.key});

  @override
  State<MainTabsView> createState() => _MainTabsViewState();
}

class _MainTabsViewState extends State<MainTabsView> {
  int _selectedIndex = 0;

  static const _tabs = [
    HostHomeView(),
    HostFeatureView(),
    IaSdkPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Host home'),
          NavigationDestination(icon: Icon(Icons.star), label: 'Host feature'),
          NavigationDestination(icon: Icon(Icons.local_pharmacy), label: 'IA SDK'),
        ],
      ),
    );
  }
}

class HostHomeView extends StatelessWidget {
  const HostHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPage(
      title: 'Host home',
      child: Text('This is the host app home screen.'),
    );
  }
}

class HostFeatureView extends StatelessWidget {
  const HostFeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPage(
      title: 'Host feature',
      child: Text('This is a host app feature, unrelated to IA SDK.'),
    );
  }
}
