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
}

/// Inline platform view widget that hosts a native SDK component.
///
/// Used by the per-component widget classes (e.g. `IaCartButton`,
/// `IaProductGrid`) exported by each module.
///
class IaSdkPlatformView extends StatefulWidget {
  /// Default constructor for creating an instance of [IaSdkPlatformView].
  ///
  const IaSdkPlatformView({
    super.key,
    required this.viewId,
    this.creationParams = const {},
    this.selfSizing = true,
  });

  /// Identifier for the currently-specified platform view object.
  ///
  final String viewId;

  /// Additional configuration parameters forwarded to native via creationParams.
  ///
  final Map<String, dynamic> creationParams;

  /// Whether the native component reports its intrinsic content size back to
  /// Flutter. When `true` (default), the component is wrapped in a
  /// [_MeasuredSizeBox] that sizes itself to the native-reported dimensions —
  /// suitable for buttons, badges, grids and any component with a finite
  /// intrinsic size.
  ///
  /// Set to `false` for components that fill the space the host provides
  /// (e.g. scrollable views). In that case the host must supply bounded
  /// constraints — typically via a [SizedBox] or [Expanded] wrapper.
  ///
  final bool selfSizing;

  @override
  State<IaSdkPlatformView> createState() {
    return _IaSdkPlatformViewState();
  }
}

class _IaSdkPlatformViewState extends State<IaSdkPlatformView> {
  int? _platformViewId;
  Size? _measuredSize;

  String get _platformViewType {
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

  Map<String, dynamic> get _creationParams => {
    'viewId': _platformViewType,
    ...widget.creationParams,
  };

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    if (widget.selfSizing) {
      _ComponentSizeDispatcher.instance.register(id, _onSizeUpdate);
    }
  }

  void _onSizeUpdate(Size size) {
    if (!mounted) return;
    if (_measuredSize != size) {
      setState(() => _measuredSize = size);
    }
  }

  @override
  void dispose() {
    if (_platformViewId != null && widget.selfSizing) {
      _ComponentSizeDispatcher.instance.unregister(_platformViewId!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget platformView;
    if (Platform.isAndroid) {
      platformView = PlatformViewLink(
        viewType: _platformViewType,
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
              viewType: _platformViewType,
              layoutDirection: TextDirection.ltr,
              creationParams: _creationParams,
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () {
                params.onFocusChanged(true);
              },
            )
            ..addOnPlatformViewCreatedListener((id) {
              _onPlatformViewCreated(id);
              params.onPlatformViewCreated(id);
            })
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      platformView = UiKitView(
        viewType: _platformViewType,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: _creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      return Text(
        'Platform not set up: ${Platform.operatingSystem}',
      );
    }

    if (!widget.selfSizing) return platformView;
    return _MeasuredSizeBox(measuredSize: _measuredSize, child: platformView);
  }
}

/// Wraps a self-sizing platform view in a [SizedBox] sized to the native
/// component's reported intrinsic size. Falls back to a 1px height while
/// awaiting the first measurement so the platform view has bounded
/// constraints to lay out against (otherwise unbounded parents like
/// [ListView] would crash).
///
class _MeasuredSizeBox extends StatelessWidget {
  const _MeasuredSizeBox({
    required this.measuredSize,
    required this.child,
  });

  final Size? measuredSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Width: null lets the parent's constraint flow through. Height defaults
      // to 1px before native reports back, which still triggers a layout pass
      // and lets the native size reporter measure the intrinsic height.
      width: measuredSize?.width,
      height: measuredSize?.height ?? 1,
      child: child,
    );
  }
}

/// Routes native component size updates to the registered [_IaSdkPlatformView].
///
/// Listens on the main SDK MethodChannel via the shared [IaBaseCallbacks]
/// system - no dedicated channel required. Auto-registers itself as a
/// subscriber on first access.
///
class _ComponentSizeDispatcher implements IaBaseCallbackHandler {
  _ComponentSizeDispatcher._() {
    // Self-register as a callback subscriber on the main SDK MethodChannel.
    IaBaseCallbacks(handlers: [this]);
  }

  static final instance = _ComponentSizeDispatcher._();

  /// Method name used by native to push size updates back to Dart.
  ///
  static const updateSizeMethodId = 'updateComponentSize';

  final _listeners = <int, ValueChanged<Size>>{};

  void register(int viewId, ValueChanged<Size> callback) {
    _listeners[viewId] = callback;
  }

  void unregister(int viewId) {
    _listeners.remove(viewId);
  }

  @override
  String get methodId => updateSizeMethodId;

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      if (args is! Map) return null;
      final viewId = (args['viewId'] as num).toInt();
      final size = Size(
        (args['width'] as num).toDouble(),
        (args['height'] as num).toDouble(),
      );
      _listeners[viewId]?.call(size);
      return null;
    };
  }
}
