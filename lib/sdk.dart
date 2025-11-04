import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

part 'callbacks.dart';
part 'config.dart';
part 'methods.dart';
part 'view.dart';

/// Base definitions for the ia.de SDK service,
/// including any relevant methods, fields, and callbacks.
///
class IaSdk extends StatefulWidget {
  /// Constructs an instance of the [IaSdk] object using the provided [configuration].
  ///
  const IaSdk({
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
  State<IaSdk> createState() {
    return IaSdkApi();
  }

  /// Returns the nearest ancestor object of the [IaSdkApi] type.
  ///
  static IaSdkApi? of(BuildContext context) {
    return context.findAncestorStateOfType<IaSdkApi>();
  }
}

/// Public API methods and properties defined for the ia.de AppSDK library usage.
///
class IaSdkApi extends State<IaSdk> {
  /// Creates a [MethodChannel] object for communication with the native library segments.
  ///
  final _channel = const MethodChannel('de.ihreapotheken/sdk');

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(
      (call) async {
        try {
          final callback = _IaPlatformCallbacks.values.firstWhere(
            (value) {
              return value.name == call.method;
            },
          );
          try {
            await callback.handle(call.arguments, this);
          } catch (e) {
            debugPrint('Callback error: ${call.method}\n$e');
          }
        } catch (e) {
          debugPrint('Callback not found: ${call.method}.');
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
    await _IaSdkPlatformMethods.initIaSdk.invoke<void>(
      widget._config.toJson(),
      this,
    );
    widget._config.initialised = true;
  }

  /// Places a new route object into the navigation stack.
  ///
  Future<void> _launchRoute(
    _IaSdkPlatformViewType view,
  ) async {
    await _IaSdkPlatformMethods.launchRoute.invoke<void>(
      view.id,
      this,
    );
  }

  /// Forwards the specified [images], [pdfs], or eRezept [codes] prescription collection to the ia.de backend.
  ///
  Future<void> transferPrescriptions({
    Iterable<Uint8List>? images,
    Iterable<Uint8List>? pdfs,
    Iterable<Iterable<String>>? codes,
    String? orderId,
  }) async {
    await _IaSdkPlatformMethods.transferPrescriptions.invoke<void>(
      {
        'images': images,
        'pdfs': pdfs,
        'codes': codes,
        'orderId': orderId,
      },
      this,
    );
  }

  /// Launches the start screen experience on top of the navigation stack.
  ///
  Future<void> launchDashboardRoute() async {
    await _launchRoute(
      _IaSdkPlatformViewType.startScreen,
    );
  }

  /// Launches the product legal disclaimer screen experience on top of the navigation stack.
  ///
  Future<void> launchLegalDisclaimerRoute() async {
    await _launchRoute(
      _IaSdkPlatformViewType.legalDisclaimerScreen,
    );
  }

  /// Launches the product search screen experience on top of the navigation stack.
  ///
  Future<void> launchProductSearchRoute() async {
    await _launchRoute(
      _IaSdkPlatformViewType.productSearchScreen,
    );
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

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    orderIdsListener.close();
    super.dispose();
  }
}
