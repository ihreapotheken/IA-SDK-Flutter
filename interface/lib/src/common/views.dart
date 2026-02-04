part of '_interface.dart';

/// Base native view definitions.
///
abstract mixin class IaBaseViews {
  /// Native identifiers required for the "launch route" method integration.
  ///
  static const launchMethodId = 'launchRoute', launchMethodArgId = 'viewId';

  /// Identifier used with native code in order to specify the view integration.
  ///
  String get viewId;

  /// Places a view integration to the native integration stack.
  ///
  Future<void> launch() async {
    return await IaBaseMethods._channel.invokeMethod(
      launchMethodId,
      {
        launchMethodArgId: Platform.isAndroid ? viewId.substring(0, 1).toUpperCase() + viewId.substring(1) : viewId,
      },
    );
  }

  /// Inline platform view [Widget] implementation.
  ///
  Widget widget({
    Key? key,
  }) {
    return _IaSdkPlatformView(
      key: key,
      viewId: viewId,
    );
  }
}

/// Platform view widget for displaying SDK screens.
///
class _IaSdkPlatformView extends StatefulWidget {
  /// Default constructor for creating an instance of [_IaSdkPlatformView].
  ///
  const _IaSdkPlatformView({
    super.key,
    required this.viewId,
  });

  /// Identifier for the currently-specified platform view object.
  ///
  final String viewId;

  @override
  State<_IaSdkPlatformView> createState() {
    return _IaSdkPlatformViewState();
  }
}

class _IaSdkPlatformViewState extends State<_IaSdkPlatformView> {
  String get _platformViewId {
    if (Platform.isAndroid) {
      return widget.viewId.substring(0, 1).toUpperCase() + widget.viewId.substring(1);
    }
    if (Platform.isIOS) {
      return widget.viewId;
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
