import 'dart:async';
import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/common/callbacks/handlers/ordering_did_finish_order_callback_handler.dart';
import 'package:appsdk_v2_flutter_plugin/common/callbacks/handlers/ordering_did_update_cart_callback_handler.dart';
import 'package:appsdk_v2_flutter_plugin/common/callbacks/handlers/sdk_will_navigate_to_target_callback_handler.dart';
import 'package:appsdk_v2_flutter_plugin/common/entities/ia_sdk_callbacks.dart';
import 'package:appsdk_v2_flutter_plugin/common/entities/ia_sdk_configuration.dart';
import 'package:appsdk_v2_flutter_plugin/common/entities/ia_sdk_module.dart';
import 'package:appsdk_v2_flutter_plugin/common/utilities/argument_validator.dart';
import 'package:appsdk_v2_flutter_plugin/common/utilities/ia_sdk_channel.dart';
import 'package:appsdk_v2_flutter_plugin/features/ia_sdk/ia_sdk_platform_view_launcher.dart';
import 'package:appsdk_v2_flutter_plugin/features/ia_ordering/ia_ordering.dart';
import 'package:appsdk_v2_flutter_plugin/features/ia_over_the_counter/ia_over_the_counter.dart';
import 'package:appsdk_v2_flutter_plugin/features/ia_pharmacy/ia_pharmacy.dart';
import 'package:appsdk_v2_flutter_plugin/features/ia_prescription/ia_prescription.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part '../../common/callbacks/ia_sdk_callback_manager.dart';

/// Widget wrapper for the ia.de SDK service.
///
/// Wraps your app to provide SDK functionality throughout the widget tree.
///
class IaSdkWidget extends StatefulWidget {
  /// Constructs an instance of the [IaSdkWidget] object using the provided [configuration].
  ///
  const IaSdkWidget({
    super.key,
    required this.child,
    required IaSdkConfiguration configuration,
  }) : _config = configuration;

  /// Property defining this [Widget] descendant.
  ///
  final Widget child;

  /// Client configuration specification.
  ///
  final IaSdkConfiguration _config;

  @override
  State<IaSdkWidget> createState() {
    return IaSdk();
  }

  /// Returns the nearest ancestor object of the [IaSdk] type.
  ///
  static IaSdk? of(BuildContext context) {
    return context.findAncestorStateOfType<IaSdk>();
  }
}

/// Public API methods and properties defined for the ia.de AppSDK library usage.
///
class IaSdk extends State<IaSdkWidget> {
  /// Gets the shared [MethodChannel] object for communication with the native library segments.
  ///
  MethodChannel get _channel => IaSdkChannel.instance.channel;

  /// Callbacks for receiving events from the SDK.
  ///
  /// Set callback functions on this object to handle SDK events such as navigation
  /// requests, state changes, and more.
  ///
  /// Example:
  /// ```dart
  /// final iaSdk = IaSdk.of(context);
  /// iaSdk?.callbacks.onShouldOverrideRoute = (route) async {
  ///   // Handle route override
  ///   return IaHandlingDecision.performDefault;
  /// };
  /// ```
  final callbacks = IaSdkCallbacks();

  /// Ordering module providing prescription transfer, cart, and checkout functionality.
  ///
  /// This mirrors the IAOrdering module from the native SDKs.
  ///
  /// Example:
  /// ```dart
  /// final iaSdk = IaSdk.of(context);
  /// await iaSdk?.ordering.transferPrescriptions(
  ///   images: [...],
  ///   codes: [...],
  /// );
  /// ```
  late final ordering = const IaOrdering();

  /// Over the counter module providing product search functionality.
  ///
  /// This mirrors the IAOverTheCounter module from the native SDKs.
  ///
  /// Example:
  /// ```dart
  /// final iaSdk = IaSdk.of(context);
  /// await iaSdk?.overTheCounter.launchProductSearchRoute();
  /// ```
  late final overTheCounter = const IaOverTheCounter();

  /// Pharmacy module providing pharmacy details functionality.
  ///
  /// This mirrors the IAPharmacy module from the native SDKs.
  ///
  /// Example:
  /// ```dart
  /// final iaSdk = IaSdk.of(context);
  /// await iaSdk?.pharmacy.launchPharmacyDetails();
  /// ```
  late final pharmacy = const IaPharmacy();

  /// Prescription module providing prescription scanning functionality.
  ///
  /// This mirrors the IAPrescription module from the native SDKs.
  ///
  /// Example:
  /// ```dart
  /// final iaSdk = IaSdk.of(context);
  /// ```
  late final prescription = const IaPrescription();

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(
      (call) async {
        try {
          final callback = IaSdkCallbackManager.values.firstWhere(
            (value) {
              return value.name == call.method;
            },
          );
          try {
            return await callback.handle(call.arguments, this);
          } catch (e) {
            debugPrint('Callback error: ${call.method}\n$e');
            return null;
          }
        } catch (e) {
          debugPrint('Callback not found: ${call.method}.');
          return null;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Instantiate ia.de SDK runtime configuration.
  ///
  /// This method must be invoked before accessing any of the available resources.
  ///
  Future<void> init() async {
    final arguments = {
      ...widget._config.toJson(),
    };

    ArgumentValidator.verify(
      arguments,
      argumentType: Map,
      requiredMapFields: [
        (
          name: 'accessKey',
          type: String,
          nullable: false,
        ),
        (
          name: 'clientId',
          type: String,
          nullable: false,
        ),
        (
          name: 'serverEnvironment',
          type: String,
          nullable: false,
        ),
      ],
    );

    await _channel.invokeMethod('initIaSdk', arguments);
  }

  /// Registers the specified SDK [modules] for use in the application.
  ///
  /// This method determines which SDK modules will be available for use.
  /// Must be called before accessing module-specific functionality.
  ///
  Future<void> register(
    List<IaSdkModule> modules,
  ) async {
    final arguments = {
      'modules': modules.map((module) => module.name).toList(),
    };

    ArgumentValidator.verify(
      arguments,
      argumentType: Map,
      requiredMapFields: [
        (
          name: 'modules',
          type: List<String>,
          nullable: false,
        ),
      ],
    );

    await _channel.invokeMethod('register', arguments);
  }

  /// Selects a pharmacy with the specified [pharmacyId].
  ///
  Future<void> setPharmacyId(
    String pharmacyId,
  ) async {
    final arguments = {
      'pharmacyId': pharmacyId,
    };

    ArgumentValidator.verify(
      arguments,
      argumentType: Map,
      requiredMapFields: [
        (
          name: 'pharmacyId',
          type: String,
          nullable: false,
        ),
      ],
    );

    await _channel.invokeMethod('setPharmacyId', arguments);
  }

  /// Forwards the client personal information to the ia.de library for checkout purposes.
  ///
  Future<void> setGuestUserData({
    required String salutation,
    required String firstName,
    required String lastName,
    required String email,
    required int phoneNumberCountryCode,
    required int phoneNumberWithoutCountryCode,
  }) async {
    final arguments = {
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumberCountryCode': phoneNumberCountryCode.toString(),
      'phoneNumberWithoutCountryCode': phoneNumberWithoutCountryCode.toString(),
    };

    ArgumentValidator.verify(
      arguments,
      argumentType: Map,
      requiredMapFields: [
        (
          name: 'salutation',
          nullable: false,
          type: String,
        ),
        (
          name: 'firstName',
          nullable: false,
          type: String,
        ),
        (
          name: 'lastName',
          nullable: false,
          type: String,
        ),
        (
          name: 'email',
          nullable: false,
          type: String,
        ),
        (
          name: 'phoneNumberCountryCode',
          nullable: true,
          type: String,
        ),
        (
          name: 'phoneNumberWithoutCountryCode',
          nullable: true,
          type: String,
        ),
      ],
    );

    await _channel.invokeMethod('setGuestUserData', arguments);
  }

  /// Resets the user data and onboarding status (pharmacy selection, user consents statuses).
  ///
  Future<void> logout() async {
    await _channel.invokeMethod('logout', null);
  }

  /// Launches the start screen experience on top of the navigation stack.
  ///
  Future<void> launchStartRoute() async {
    await IaSdkPlatformViewLauncher.launchStartRoute();
  }

  /// [StreamController] object handling completed checkout updates.
  ///
  /// The object will broadcast the information on order IDs forwarded with the [transferPrescriptions] method
  /// once the user successfully completes the checkout process.
  ///
  /// Subscribe to the listener object:
  ///
  /// ```dart
  /// final iaSdk = IaSdk( ... );
  /// final iaSdkOrderIdsSubscription = iaSdk.orderIdsListener.stream.listen((data) {
  ///   ...
  /// });
  /// iaSdk.iaSdkOrderIdsSubscription.cancel(); // Dispose resources on finish.
  /// ```
  ///
  final orderIdsListener = StreamController<List<String>>.broadcast();

  /// Closes any overlaying ia.de screen contents.
  ///
  Future<void> finishAllActivities() async {
    await _channel.invokeMethod('finishAllActivities', null);
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    orderIdsListener.close();
    super.dispose();
  }
}
