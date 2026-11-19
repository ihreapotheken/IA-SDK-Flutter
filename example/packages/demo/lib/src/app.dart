import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_example_demo/ia_client_config.dart';
import 'package:ia_example_demo/src/e2e/e2e_config.dart';
import 'package:ia_example_demo/src/e2e/e2e_harness.dart';
import 'package:ia_example_demo/src/file_utils.dart';
import 'package:ia_example_demo/src/testing/event_log.dart';
import 'package:ia_example_demo/src/testing/test_settings.dart';
import 'package:ia_example_demo/src/views/cardlink_view.dart';
import 'package:ia_example_demo/src/views/home_view.dart';
import 'package:ia_example_demo/src/views/components_view.dart';
import 'package:ia_example_demo/src/views/embedded_view.dart';
import 'package:ia_example_demo/src/views/events_view.dart';
import 'package:ia_example_demo/src/views/screens_view.dart';
import 'package:ia_example_demo/src/views/services_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ia_cardlink/ia_cardlink.dart';
import 'package:ia_example_shared/ia_example_shared.dart';
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

  /// Tabs built on their first visit: their SDK components and screens start the prerequisites when they're created,
  /// which on Android happens even while the tab is hidden, so they'd open at app start.
  final _shownLazyTabIndexes = <int>{};

  static const _componentsTabIndex = 4, _embeddedTabIndex = 5;
  static const _lazyTabIndexes = {_componentsTabIndex, _embeddedTabIndex};
  bool _isInitialized = false;
  late Future<void> _initFuture = _initializeSdk();

  static const _navigationItems = <({String label, IconData icon})>[
    (label: 'Host App', icon: Icons.map_outlined),
    (label: 'CardLink', icon: Icons.nfc_rounded),
    (label: 'Services', icon: Icons.tune_rounded),
    (label: 'Screens', icon: Icons.layers_outlined),
    (label: 'Components', icon: Icons.widgets_outlined),
    (label: 'Embedded', icon: Icons.web_asset_rounded),
    (label: 'Events', icon: Icons.receipt_long_outlined),
  ];

  static final _platformLine =
      'Flutter · ${Platform.isIOS ? 'iOS' : 'Android'} AppSDK '
      '${dotenv.env['${Platform.isIOS ? 'IOS' : 'ANDROID'}_APPSDK_VERSION'] ?? 'N/A'} · '
      '${ExampleAppConfig.instance.serverEnvironmentLabel}';

  Future<void> _initializeSdk() async {
    if (_isInitialized) return;

    final log = ExampleEventLog.instance;
    final analyticsLog = ExampleEventLog.analytics;
    final settings = ExampleTestSettings.instance;

    IaSdk.instance.onSdkWillNavigateToTarget = (navigationTarget) async {
      // The E2E harness has no host destinations to navigate to — let the SDK
      // handle every target internally so the flows match the native demos.
      final isHandledByHost = !E2EConfig.enabled && settings.handlesNavigation;
      log.add('Navigation', '${navigationTarget.name}${isHandledByHost ? ', handled by the host' : ''}');
      return !isHandledByHost;
    };

    IaSdk.instance.onApofinderDidChangePharmacy =
        ({
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

    IaSdk.instance.loggedAnalyticsEventListener.stream.listen(
      (event) => analyticsLog.add('SDK', event.toJson()),
    );

    ExampleAppConfig.instance.hostAppLogFilePath = await FileUtils.createDemoCoreAppLogFile();

    // E2E runs keep the defaults, so settings cached by an earlier manual run don't change the flows they drive.
    if (!E2EConfig.enabled) {
      try {
        await ExampleAppConfig.instance.loadStartupSettings();
      } catch (e) {
        log.add('Settings', 'Cached settings not loaded, using the defaults: $e');
      }
    }

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
      (event) => analyticsLog.add('CardLink', event),
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
      theme: iaExampleTheme(),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
        child: FutureBuilder(
          future: _initFuture,
          builder: (context, snapshot) {
            final isDone = snapshot.connectionState == ConnectionState.done;
            final isReady = isDone && !snapshot.hasError;
            // The embedded SDK screen shows its own header, so the app's is hidden on its tab.
            final isHeaderHidden = isReady && _selectedTabIndex == _embeddedTabIndex;
            return Scaffold(
              body: Column(
                children: [
                  // Kept in the tree when hidden, so the tabs below keep their state.
                  if (isHeaderHidden)
                    const SizedBox.shrink()
                  else
                    IaBrandHeader(
                      product: 'AppSDK Demo',
                      subtitle: _platformLine,
                      status: IaStatusPill(
                        label: !isDone
                            ? 'Initializing'
                            : isReady
                            ? 'Initialized'
                            : 'Error',
                        isReady: isReady,
                      ),
                    ),
                  Expanded(
                    // A context in the body, whose padding excludes the tab bar's.
                    child: Builder(
                      builder: (context) => MediaQuery.removePadding(
                        context: context,
                        removeTop: !isHeaderHidden,
                        child: !isDone
                            ? const Center(child: CircularProgressIndicator())
                            : snapshot.hasError
                            ? _InitializationError(
                                error: snapshot.error!,
                                onRetry: () => setState(() => _initFuture = _initializeSdk()),
                              )
                            : IndexedStack(
                                index: _selectedTabIndex,
                                children: [
                                  const HomeView(),
                                  const CardLinkView(),
                                  const ServicesView(),
                                  const ScreensView(),
                                  _shownLazyTabIndexes.contains(_componentsTabIndex) ? const ComponentsView() : const SizedBox.shrink(),
                                  _shownLazyTabIndexes.contains(_embeddedTabIndex) ? const EmbeddedView() : const SizedBox.shrink(),
                                  const EventsView(),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: isReady
                  ? IaTabBar(
                      tabs: _navigationItems,
                      selectedIndex: _selectedTabIndex,
                      onSelected: (index) {
                        setState(() {
                          _selectedTabIndex = index;
                          if (_lazyTabIndexes.contains(index)) _shownLazyTabIndexes.add(index);
                        });
                      },
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}

/// Why the SDK didn't initialize, with a button that tries again.
///
class _InitializationError extends StatelessWidget {
  const _InitializationError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(IaSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: IaSpacing.lg,
          children: [
            const Text('The SDK didn\'t initialize', style: IaTextStyles.title),
            Text(error.toString(), textAlign: TextAlign.center, style: IaTextStyles.caption),
            IaButton(title: 'Retry', onTap: onRetry),
          ],
        ),
      ),
    );
  }
}
