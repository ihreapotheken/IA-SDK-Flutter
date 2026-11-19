import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ia_example_shared/ia_example_shared.dart';
import 'package:ia_example_single_entry_point/src/components/tab_page.dart';
import 'package:ia_example_single_entry_point/src/ia_sdk_page.dart';

class SingleEntryPointApp extends StatelessWidget {
  const SingleEntryPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IA SDK Single Entry Point',
      debugShowCheckedModeBanner: false,
      theme: iaExampleTheme(),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        child: const MainTabsView(),
      ),
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
      bottomNavigationBar: IaTabBar(
        tabs: const [
          (label: 'Host home', icon: Icons.home_outlined),
          (label: 'Host feature', icon: Icons.star_outline_rounded),
          (label: 'IA SDK', icon: Icons.local_pharmacy_outlined),
        ],
        selectedIndex: _selectedIndex,
        onSelected: (index) => setState(() => _selectedIndex = index),
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
      child: Text('This is the host app home screen.', textAlign: TextAlign.center, style: IaTextStyles.body),
    );
  }
}

class HostFeatureView extends StatelessWidget {
  const HostFeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPage(
      title: 'Host feature',
      child: Text('This is a host app feature, unrelated to IA SDK.', textAlign: TextAlign.center, style: IaTextStyles.body),
    );
  }
}
