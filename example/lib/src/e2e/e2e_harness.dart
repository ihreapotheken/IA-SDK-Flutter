import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// A single harness tab: a host-owned button that swaps the embedded SDK screen.
///
typedef _HarnessTab = ({
  /// Semantics identifier — surfaces as `resource-id` on Android and
  /// `accessibilityIdentifier` on iOS, giving the test suite a stable selector.
  String identifier,

  /// Visible label. Matches the corresponding native demo app tab so the
  /// shared test flows read the same on every host.
  String label,

  /// Platform view identifier of the SDK screen this tab embeds, or null for a
  /// host-owned screen.
  String? viewId,

  IconData icon,
});

/// Minimal host UI used by the shared e2e-tests suite.
///
/// Mirrors the structure of the native demo apps: a host-owned bottom tab bar
/// that swaps a full-screen embedded SDK screen. Because the SDK content is the
/// same native UI in every host, the test flows and their SDK selectors carry
/// over unchanged — only the host chrome selectors differ, and those are
/// resolved through the suite's per-target element overlay.
///
/// The prerequisite flow (onboarding → legal → Apofinder) is driven by the SDK
/// itself when the start screen is shown without completed prerequisites, so
/// tests see the same entry sequence as on the native demo apps.
///
class E2EHarness extends StatefulWidget {
  /// Default constructor for creating an instance of [E2EHarness].
  ///
  const E2EHarness({super.key});

  @override
  State<E2EHarness> createState() => _E2EHarnessState();
}

class _E2EHarnessState extends State<E2EHarness> {
  /// Keeps Flutter's semantics tree alive for the whole run.
  ///
  /// Flutter only builds semantics while something requests them. Appium and
  /// Maestro read the platform accessibility tree, so without this the host
  /// chrome would be invisible to the runner until an accessibility service
  /// happened to attach.
  ///
  SemanticsHandle? _semanticsHandle;

  int _selectedIndex = 0;

  /// Host tabs, labelled to match the native demo app of the running platform
  /// (IA-SDK-Dev-Android's `BottomTab` / IASDKDevDemo's `DemoRootTab`).
  ///
  static final _tabs = <_HarnessTab>[
    (
      identifier: 'tab_start',
      label: Platform.isIOS ? 'Start' : 'Startseite',
      viewId: 'startScreen',
      icon: Icons.home,
    ),
    (
      identifier: 'tab_search',
      label: 'Search',
      viewId: 'searchScreen',
      icon: Icons.search,
    ),
    (
      identifier: 'tab_cart',
      label: Platform.isIOS ? 'Cart' : 'Warenkorb',
      viewId: 'cartScreen',
      icon: Icons.shopping_cart,
    ),
    (
      identifier: 'tab_pharmacy',
      label: 'Pharmacy',
      viewId: 'pharmacyScreen',
      icon: Icons.local_pharmacy,
    ),
    (
      identifier: 'tab_settings',
      label: 'Settings',
      viewId: null,
      icon: Icons.settings,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _semanticsHandle = SemanticsBinding.instance.ensureSemantics();
  }

  @override
  void dispose() {
    _semanticsHandle?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = _tabs[_selectedIndex];

    final selectedViewId = selectedTab.viewId;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: selectedViewId == null
                ? const _HarnessSettingsScreen()
                // Keyed by view ID so switching tabs disposes the previous SDK
                // screen and creates the next one, matching how the native demo
                // apps replace the navigation destination on a tab switch.
                : IaSdkPlatformView(
                    key: ValueKey(selectedViewId),
                    viewId: selectedViewId,
                    selfSizing: false,
                  ),
          ),
          _HarnessTabBar(
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            onTabSelected: (index) => setState(() => _selectedIndex = index),
          ),
        ],
      ),
    );
  }
}

/// Host-owned settings screen, standing in for the native demo app's QA
/// controls.
///
/// The demo apps can enable the SDK's internal QA affordances (the
/// "Apotheken-ID eingeben" sheet in Apofinder) through `setQaConfiguration`,
/// which the wrappers don't expose. Selecting the test pharmacy by ID is the
/// equivalent the wrappers *do* expose, so the harness offers it here — that
/// keeps flows which need pharmacy 2163 deterministic instead of depending on
/// live Apofinder search results.
///
class _HarnessSettingsScreen extends StatefulWidget {
  const _HarnessSettingsScreen();

  @override
  State<_HarnessSettingsScreen> createState() => _HarnessSettingsScreenState();
}

class _HarnessSettingsScreenState extends State<_HarnessSettingsScreen> {
  /// Test pharmacy used by the shared test flows.
  ///
  static const _testPharmacyId = '2163';

  String _status = '';

  Future<void> _useTestPharmacy() async {
    try {
      await IaSdk.instance.pharmacy.setPharmacyId(_testPharmacyId);
      setState(() => _status = 'Pharmacy set to $_testPharmacyId');
    } catch (e) {
      setState(() => _status = 'Failed to set pharmacy: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'E2E harness',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            MergeSemantics(
              child: Semantics(
                identifier: 'host_use_test_pharmacy',
                button: true,
                child: ElevatedButton(
                  onPressed: _useTestPharmacy,
                  child: Text('Use Test Pharmacy ($_testPharmacyId)'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              identifier: 'host_status',
              child: Text(_status),
            ),
          ],
        ),
      ),
    );
  }
}

class _HarnessTabBar extends StatelessWidget {
  const _HarnessTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  final List<_HarnessTab> tabs;

  final int selectedIndex;

  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0x1F000000))),
        color: Colors.white,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        child: Row(
          children: [
            for (final (index, tab) in tabs.indexed)
              Expanded(
                child: MergeSemantics(
                  child: Semantics(
                    identifier: tab.identifier,
                    button: true,
                    selected: index == selectedIndex,
                    child: InkWell(
                      onTap: () => onTabSelected(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.icon,
                            size: 22,
                            color: index == selectedIndex
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black54,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: index == selectedIndex
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
