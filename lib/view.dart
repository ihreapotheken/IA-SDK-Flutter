part of 'sdk.dart';

enum _IaSdkPlatformViewType {
  /// Dashboard screen displaying main app content.
  ///
  startScreen,

  /// Pharmacy finder main entry screen.
  ///
  legalDisclaimerScreen,

  /// Shop screen with product search and filtering options.
  ///
  productSearchScreen,
}

class IaSdkPlatformView extends StatefulWidget {
  /// Dashboard screen displaying main app content.
  ///
  const IaSdkPlatformView.startScreen({
    super.key,
  }) : _platformViewType = _IaSdkPlatformViewType.startScreen;

  /// Dashboard screen displaying main app content.
  ///
  const IaSdkPlatformView.legalDisclaimerScreen({
    super.key,
  }) : _platformViewType = _IaSdkPlatformViewType.legalDisclaimerScreen;

  /// Dashboard screen displaying main app content.
  ///
  const IaSdkPlatformView.productSearchScreen({
    super.key,
  }) : _platformViewType = _IaSdkPlatformViewType.productSearchScreen;

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
              creationParams: {
                'viewId': widget._platformViewType.name,
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
