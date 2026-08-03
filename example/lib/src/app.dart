import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/ia_client_config.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/e2e/e2e_config.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/e2e/e2e_harness.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/cardlink_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/home_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/components_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/screens_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/services_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ia_cardlink/ia_cardlink.dart';
import 'package:ia_ordering/ia_ordering.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';
import 'package:ia_pharmacy/ia_pharmacy.dart';
import 'package:ia_prescription/ia_prescription.dart';

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  int _selectedTabIndex = 0;
  bool _isInitialized = false;
  late Future<void> _initFuture = _initializeSdk();

  static const _navigationItems = <({String label, IconData icon})>[
    (label: 'Host App', icon: Icons.home),
    (label: 'CardLink', icon: Icons.nfc),
    (label: 'Services', icon: Icons.category),
    (label: 'Screens', icon: Icons.screenshot),
    (label: 'Components', icon: Icons.widgets),
  ];

  Future<void> _initializeSdk() async {
    if (_isInitialized) return;

    IaSdk.instance.onSdkWillNavigateToTarget = (navigationTarget) async {
      debugPrint('Host app: SDK wants to navigate to: $navigationTarget');
      // The E2E harness has no host destinations to navigate to — let the SDK
      // handle every target internally so the flows match the native demos.
      return !E2EConfig.enabled;
    };

    IaSdk.instance.onApofinderDidChangePharmacy = ({
      required pharmacyId,
      required isFromPrerequisites,
    }) {
      debugPrint(
        'Host app: Apofinder changed pharmacy to $pharmacyId (fromPrerequisites: $isFromPrerequisites)',
      );
    };

    await IaSdk.instance.register(
      modules: [
        IaModuleCardLink(),
        IaModuleOrdering(),
        IaModuleOverTheCounter(),
        IaModulePharmacy(),
        IaModulePrescription(),
      ],
    );

    await IaSdk.instance.initialize(
      config: ExampleAppConfig.instance.pluginConfig,
    );

    IaSdk.instance.ordering.orderingDidFinishOrderListener.stream.listen(
      (order) {
        debugPrint(
          'Host app: Order completed! Order Code: ${order.orderCode}, client order ID: ${order.clientOrderIDs}',
        );
      },
    );

    IaSdk.instance.ordering.orderingDidUpdateCartListener.stream.listen(
      (cart) {
        debugPrint(
          'Host app: Cart updated - ${cart.totalAmountInCart} items, ${cart.clientOrderIDs.length} orders',
        );
      },
    );

    IaSdk.instance.cardLink.consentEventListener.stream.listen(
      (event) => debugPrint('Host app: CardLink consent event: $event'),
    );

    IaSdk.instance.cardLink.sessionCreatedListener.stream.listen(
      (session) => debugPrint(
        'Host app: CardLink session created - data: ${session.data}',
      ),
    );

    IaSdk.instance.cardLink.prescriptionsRedeemedListener.stream.listen(
      (prescriptions) => debugPrint(
        'Host app: CardLink prescriptions redeemed: $prescriptions',
      ),
    );

    IaSdk.instance.cardLink.eventListener.stream.listen(
      (event) => debugPrint('Host app: CardLink event: $event'),
    );

    IaSdk.instance.cardLink.analyticsEventListener.stream.listen(
      (event) => debugPrint('Host app: CardLink analytics event: $event'),
    );

    if (E2EConfig.enabled && E2EConfig.pharmacyId.isNotEmpty) {
      await IaSdk.instance.pharmacy.setPharmacyId(E2EConfig.pharmacyId);
    }

    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    if (E2EConfig.enabled) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'SDK init failed: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }
            return const E2EHarness();
          },
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'AppSDK Flutter Demo'
            ' | '
            '${Platform.isIOS ? 'iOS' : 'Android'}'
            ' ${dotenv.env['${Platform.isIOS ? 'IOS' : 'ANDROID'}_APPSDK_VERSION'] ?? 'N/A'}'
            ' | '
            '${ExampleAppConfig.instance.serverEnvironmentLabel}',
            style: const TextStyle(fontSize: 14),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _initFuture = _initializeSdk();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _selectedTabIndex,
                    children: const [
                      HomeView(),
                      CardLinkView(),
                      ServicesView(),
                      ScreensView(),
                      ComponentsView(),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration:
                      BoxDecoration(border: Border(top: BorderSide())),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                    ),
                    child: Row(
                      children: [
                        for (final (index, item)
                            in _navigationItems.indexed)
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
                ),
              ],
            );
          },
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
