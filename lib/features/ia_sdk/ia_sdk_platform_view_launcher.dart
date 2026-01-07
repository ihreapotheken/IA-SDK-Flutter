import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/common/utilities/argument_validator.dart';
import 'package:appsdk_v2_flutter_plugin/common/utilities/ia_sdk_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Launcher for platform-specific SDK views.
///
class IaSdkPlatformViewLauncher {
  const IaSdkPlatformViewLauncher._();

  /// Launches the start screen experience on top of the navigation stack.
  ///
  static Future<void> launchStartRoute() async {
    await _launchRoute('startScreen');
  }

  /// Launches the product search screen experience on top of the navigation stack.
  ///
  static Future<void> launchProductSearchRoute() async {
    await _launchRoute('searchScreen');
  }

  /// Launches the cart screen experience on top of the navigation stack.
  ///
  static Future<void> launchCartScreen() async {
    await _launchRoute('cartScreen');
  }

  /// Launches the pharmacy details screen experience on top of the navigation stack.
  ///
  static Future<void> launchPharmacyDetails() async {
    await _launchRoute('pharmacyScreen');
  }

  /// Places a new route object into the navigation stack.
  ///
  static Future<void> _launchRoute(String viewId) async {
    final arguments = {
      'viewId': _getPlatformViewId(viewId),
    };

    ArgumentValidator.verify(
      arguments,
      argumentType: Map,
      requiredMapFields: [
        (
          name: 'viewId',
          type: String,
          nullable: false,
        ),
      ],
    );

    await IaSdkChannel.instance.channel.invokeMethod('launchRoute', arguments);
  }

  /// Converts view ID to platform-specific format.
  ///
  static String _getPlatformViewId(String viewId) {
    if (Platform.isAndroid) {
      // Android expects PascalCase
      return viewId.substring(0, 1).toUpperCase() + viewId.substring(1);
    }
    if (Platform.isIOS) {
      // iOS expects camelCase
      return viewId;
    }
    throw Exception(
      'Unsupported platform: ${Platform.operatingSystem}.',
    );
  }
}

/// Platform view widget for displaying SDK screens.
///
class IaSdkPlatformView extends StatefulWidget {
  /// Start screen displaying main app content.
  ///
  const IaSdkPlatformView.startScreen({
    super.key,
  }) : _viewId = 'startScreen';

  /// Product search screen with product search and filtering options.
  ///
  const IaSdkPlatformView.productSearchScreen({
    super.key,
  }) : _viewId = 'searchScreen';

  /// Cart screen displaying shopping cart from IAOrdering module.
  ///
  const IaSdkPlatformView.cartScreen({
    super.key,
  }) : _viewId = 'cartScreen';

  /// Pharmacy details screen from IAPharmacy module.
  ///
  const IaSdkPlatformView.pharmacyDetails({
    super.key,
  }) : _viewId = 'pharmacyScreen';

  /// Identifier for the currently-specified platform view object.
  ///
  final String _viewId;

  @override
  State<IaSdkPlatformView> createState() {
    return _IaSdkPlatformViewState();
  }
}

class _IaSdkPlatformViewState extends State<IaSdkPlatformView> {
  String get _platformViewId {
    if (Platform.isAndroid) {
      return widget._viewId.substring(0, 1).toUpperCase() + widget._viewId.substring(1);
    }
    if (Platform.isIOS) {
      return widget._viewId;
    }
    throw Exception(
      'Unsupported platform: ${Platform.operatingSystem}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: _platformViewId,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: _platformViewId,
              layoutDirection: TextDirection.ltr,
              creationParams: {
                'viewId': _platformViewId,
              },
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    }
    if (Platform.isIOS) {
      return UiKitView(
        viewType: _platformViewId,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: _platformViewId,
      );
    }
    return Text(
      'Platform not set up: ${Platform.operatingSystem}',
    );
  }
}
