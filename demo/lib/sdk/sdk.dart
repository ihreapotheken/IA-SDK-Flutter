import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

part 'config.dart';
part 'methods.dart';
part 'view.dart';

/// Base definitions for the ia.de SDK service,
/// including any relevant methods, fields, and callbacks.
///
class IaSdk {
  /// Constructs an instance of the [IaSdk] object using the provided [configuration].
  ///
  IaSdk({
    required IaSdkConfiguration configuration,
  }) : _config = configuration;

  /// Client configuration specification.
  ///
  final IaSdkConfiguration _config;

  /// Instantiate ia.de SDK runtime configuration.
  ///
  /// This method must be invoked before accessing any of the available resources.
  ///
  Future<void> init() async {
    await _IaSdkPlatformMethods.initIaSdk.invoke<void>(
      _config.toJson(),
    );
    _config.initialised = true;
  }

  /// Places a new route object into the navigation stack.
  ///
  Future<void> _launchRoute(
    String viewId,
  ) async {
    await _IaSdkPlatformMethods.launchRoute.invoke<void>(
      viewId,
    );
  }

  /// Forwards the specified [images], [pdfs], or eRezept [codes] prescription collection to the ia.de backend.
  ///
  Future<void> transferPrescriptions({
    Iterable<Uint8List>? images,
    Iterable<Uint8List>? pdfs,
    Iterable<Iterable<String>>? codes,
  }) async {
    await _IaSdkPlatformMethods.transferPrescriptions.invoke<void>(
      {
        'images': images,
        'pdfs': pdfs,
        'codes': codes,
      },
    );
  }

  /// Launches the start screen experience on top of the navigation stack.
  ///
  Future<void> launchDashboardRoute() async {
    await _launchRoute(
      _IaSdkPlatformViewType.startScreen.name,
    );
  }

  /// Launches the product legal disclaimer screen experience on top of the navigation stack.
  ///
  Future<void> launchLegalDisclaimerRoute() async {
    await _launchRoute(
      _IaSdkPlatformViewType.legalDisclaimerScreen.name,
    );
  }

  /// Launches the product search screen experience on top of the navigation stack.
  ///
  Future<void> launchProductSearchRoute() async {
    await _launchRoute(
      _IaSdkPlatformViewType.productSearchScreen.name,
    );
  }
}
