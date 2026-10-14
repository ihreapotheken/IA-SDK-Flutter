import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/ia_client_config.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/e2e/e2e_config.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/e2e/e2e_harness.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/file_utils.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/testing/event_log.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/testing/test_settings.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/cardlink_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/home_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/components_view.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/views/events_view.dart';
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
    (label: 'Events', icon: Icons.receipt_long),
  ];

  Future<void> _initializeSdk() async {
    if (_isInitialized) return;

    final log = ExampleEventLog.instance;
    final settings = ExampleTestSettings.instance;

    IaSdk.instance.onSdkWillNavigateToTarget = (navigationTarget) async {
      // The E2E harness has no host destinations to navigate to — let the SDK
      // handle every target internally so the flows match the native demos.
      final isHandledByHost = !E2EConfig.enabled && settings.handlesNavigation;
      log.add('Navigation', '${navigationTarget.name}${isHandledByHost ? ', handled by the host' : ''}');
      return !isHandledByHost;
    };

    IaSdk.instance.onApofinderDidChangePharmacy = ({
      required pharmacyId,
      required isFromPrerequisites,
    }) {
      log.add('Apofinder', 'Pharmacy $pharmacyId selected (from prerequisites: $isFromPrerequisites)');
    };

    IaSdk.instance.onSdkBackAction = () async {
      final closes = !settings.blocksBackAction;
      log.add('Back action', closes ? 'Screen closes' : 'Screen stays open');
      return closes;
    };

    IaSdk.instance.initializationStateListener.stream.listen(
      (state) => log.add('Initialization', state.name),
    );

    IaSdk.instance.prerequisitesResultListener.stream.listen(
      (result) => log.add(
        'Prerequisites',
        'cancelled: ${result.isCancelled}, onboarding: ${result.onboarding?.name}, '
            'legal: ${result.legal?.name}, pharmacy: ${result.pharmacyId}',
      ),
    );

    IaSdk.instance.analyticsEventListener.stream.listen(
      (event) => log.add('Analytics', '${event.type} ${event.parameters}'),
    );

    ExampleAppConfig.instance.hostAppLogFilePath = await FileUtils.createDemoCoreAppLogFile();

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
      (order) => log.add(
        'Order',
        'Completed, order codes: ${order.orderCodes}, client order IDs: ${order.clientOrderIDs}',
      ),
    );

    IaSdk.instance.ordering.orderingDidUpdateCartListener.stream.listen(
      (cart) => log.add(
        'Cart',
        '${cart.totalAmountInCart} items (products: ${cart.totalProducts}, prescriptions: ${cart.totalPrescriptions}), '
            'products: ${cart.products?.map((product) => '${product.pzn} x${product.amount}').join(', ')}',
      ),
    );

    IaSdk.instance.prescription.onPrescriptionPhotoScanned = (imageData) async {
      final decision = settings.scanDecision;
      log.add('Prescription', 'Photo scanned (${imageData.length} bytes), answer: ${decision.name}');
      return decision.sdkDecision;
    };

    IaSdk.instance.prescription.onEPrescriptionScanned = (scan) async {
      final decision = settings.scanDecision;
      log.add('Prescription', 'E-prescription scanned (${scan.urls.length} prescriptions), answer: ${decision.name}');
      return decision.sdkDecision;
    };

    IaSdk.instance.prescription.scannerCameraErrorListener.stream.listen(
      (message) => log.add('Scanner camera', message),
    );

    final cardLink = IaSdk.instance.cardLink;
    cardLink.consentEventListener.stream.listen(
      (event) => log.add('CardLink', 'Consent ${event.name}'),
    );
    cardLink.consentPhoneNumberListener.stream.listen(
      (phoneNumber) => log.add('CardLink', 'Consent phone number $phoneNumber'),
    );
    cardLink.sessionCreatedListener.stream.listen(
      (session) => log.add('CardLink', 'Session created: ${session.data}'),
    );
    cardLink.prescriptionsRedeemedListener.stream.listen(
      (prescriptions) => log.add('CardLink', 'Prescriptions redeemed: $prescriptions'),
    );
    cardLink.eventListener.stream.listen(
      (event) => log.add('CardLink', 'Event ${event.name}'),
    );
    cardLink.savedCardsListener.stream.listen(
      (cards) => log.add('CardLink', 'Saved cards: ${cards.map((card) => card.name).join(', ')}'),
    );
    cardLink.initializationErrorListener.stream.listen(
      (message) => log.add('CardLink', 'Failed to initialize: ${message ?? 'no description'}'),
    );
    cardLink.resultListener.stream.listen(
      (result) => log.add('CardLink', 'Result: $result'),
    );
    cardLink.analyticsEventListener.stream.listen(
      (event) => log.add('CardLink', 'Analytics: $event'),
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
                      EventsView(),
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
