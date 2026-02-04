import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/ia_client_config.dart';
import 'package:flutter/foundation.dart';
import 'package:ia_cardlink/ia_cardlink.dart';
import 'package:ia_ordering/ia_ordering.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';
import 'package:ia_pharmacy/ia_pharmacy.dart';
import 'package:ia_prescription/ia_prescription.dart';

class SdkInitializer {
  SdkInitializer._();

  static final instance = SdkInitializer._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _setupCallbacks();
    await _registerModules();
    await _initializeSdk();
    _setupEventListeners();

    _isInitialized = true;
  }

  void _setupCallbacks() {
    IaSdk.instance.onSdkWillNavigateToTarget = (navigationTarget) async {
      debugPrint('Host app: SDK wants to navigate to: $navigationTarget');

      switch (navigationTarget) {
        case IaSdkNavigationTarget.pharmacyDetails:
          return true;
        default:
          return true;
      }
    };
  }

  Future<void> _registerModules() async {
    await IaSdk.instance.register(
      modules: [
        IaModuleCardLink(),
        IaModuleOrdering(),
        IaModuleOverTheCounter(),
        IaModulePharmacy(),
        IaModulePrescription(),
      ],
    );
  }

  Future<void> _initializeSdk() async {
    await IaSdk.instance.initialize(
      config: ExampleAppConfig.instance.pluginConfig,
    );
  }

  void _setupEventListeners() {
    // Ordering listeners
    IaSdk.instance.ordering.orderingDidFinishOrderListener.stream.listen(
      (order) {
        debugPrint(
          'Host app: Order completed! Order Code: ${order.orderCode}, client order ID: ${order.clientOrderIDs}',
        );
      },
    );

    IaSdk.instance.ordering.orderingDidUpdateCartListener.stream.listen(
      (cart) {
        final itemCount = cart.totalAmountInCart;
        final orderCount = cart.clientOrderIDs.length;
        debugPrint(
          'Host app: Cart updated - $itemCount items, $orderCount orders',
        );
      },
    );

    // CardLink listeners
    IaSdk.instance.cardLink.consentEventListener.stream.listen(
      (event) {
        debugPrint('Host app: CardLink consent event: $event');
      },
    );

    IaSdk.instance.cardLink.sessionCreatedListener.stream.listen(
      (session) {
        debugPrint(
          'Host app: CardLink session created - data: ${session.data}',
        );
      },
    );

    IaSdk.instance.cardLink.prescriptionsRedeemedListener.stream.listen(
      (prescriptions) {
        debugPrint('Host app: CardLink prescriptions redeemed: $prescriptions');
      },
    );

    IaSdk.instance.cardLink.eventListener.stream.listen(
      (event) {
        debugPrint('Host app: CardLink event: $event');
      },
    );

    IaSdk.instance.cardLink.analyticsEventListener.stream.listen(
      (event) {
        debugPrint('Host app: CardLink analytics event: $event');
      },
    );
  }
}
