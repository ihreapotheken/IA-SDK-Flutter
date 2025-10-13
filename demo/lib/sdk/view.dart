import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

enum _IaSdkPlatformViewType {
  productSearchScreen,
  cartScreen,
}

class IaSdkPlatformView extends StatefulWidget {
  const IaSdkPlatformView.productSearch({
    super.key,
  }) : _platformViewType = _IaSdkPlatformViewType.productSearchScreen;

  const IaSdkPlatformView.cartScreen({
    super.key,
  }) : _platformViewType = _IaSdkPlatformViewType.cartScreen;

  /// Identifier for the currently-specified platform view object.
  ///
  final _IaSdkPlatformViewType _platformViewType;

  @override
  State<IaSdkPlatformView> createState() {
    return _IaSdkPlatformViewState();
  }
}

class _IaSdkPlatformViewState extends State<IaSdkPlatformView> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: widget._platformViewType.name,
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
              viewType: widget._platformViewType.name,
              layoutDirection: TextDirection.ltr,
              creationParams: null,
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
        viewType: widget._platformViewType.name,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: widget._platformViewType.name,
      );
    }
    return Text(
      'Platform not set up: ${Platform.operatingSystem}',
    );
  }
}
