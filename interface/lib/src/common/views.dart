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
  /// Screen options are forwarded as [arguments], next to the view identifier.
  ///
  Future<void> launch({
    Map<String, dynamic> arguments = const {},
  }) async {
    IaBaseCallbacks._ensureSharedChannelHandler();
    return await IaBaseMethods._channel.invokeMethod(
      launchMethodId,
      {
        ...arguments,
        launchMethodArgId: Platform.isAndroid ? viewId.substring(0, 1).toUpperCase() + viewId.substring(1) : viewId,
      },
    );
  }
}

/// How an SDK screen embedded with [IaSdkPlatformView] is shown by the host, which decides the button the SDK puts in
/// its navigation bar.
///
/// Note: Only supported on iOS. The Android SDK has no embed options, so there the screen shows no back or close
/// button and the system back action closes it.
///
enum IaSdkScreenEmbedStyle {
  /// The host pushed the screen; the SDK shows a back button.
  navigation,

  /// The host presented the screen; the SDK shows a close button.
  presentation,
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
    this.onTap,
    this.embedStyle,
    this.onDismiss,
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

  /// Called when the native component is tapped, instead of the component's own tap action.
  ///
  /// Only used by components that support it (e.g. `IaCartButton`).
  ///
  final VoidCallback? onTap;

  /// How the host shows this SDK screen, see [IaSdkScreenEmbedStyle]. When `null`, the SDK shows no back or close
  /// button.
  ///
  /// Only used by SDK screens (e.g. `searchScreen`), not by components.
  ///
  /// Note: Only supported on iOS.
  ///
  final IaSdkScreenEmbedStyle? embedStyle;

  /// Called when the user taps the SDK's back or close button, shown because of [embedStyle]. The SDK doesn't close
  /// the screen itself, the host does, typically with `Navigator.of(context).pop()`.
  ///
  /// Note: Only supported on iOS.
  ///
  final VoidCallback? onDismiss;

  @override
  State<IaSdkPlatformView> createState() {
    return _IaSdkPlatformViewState();
  }
}

class _IaSdkPlatformViewState extends State<IaSdkPlatformView> {
  int? _platformViewId;
  Size? _measuredSize;

  /// Width the parent offered in the latest layout, and when [_measuredSize] was reported.
  double? _availableWidth;
  double? _measuredAvailableWidth;

  @override
  void initState() {
    super.initState();
    // Size and tap updates arrive on the shared channel.
    IaBaseCallbacks._ensureSharedChannelHandler();
  }

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
    'hasTapHandler': widget.onTap != null,
    if (widget.embedStyle != null) 'embedStyle': widget.embedStyle!.name,
    ...widget.creationParams,
  };

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;
    if (widget.selfSizing) {
      _ComponentSizeDispatcher.instance.register(id, _onSizeUpdate);
    }
    // Looked up on each tap, so a rebuilt widget's new callback is used. Whether native reports taps at all
    // is fixed at creation, see IaCartButton.
    _ComponentTapDispatcher.instance.register(id, () => widget.onTap?.call());
    _ScreenDismissDispatcher.instance.register(id, () => widget.onDismiss?.call());
  }

  void _onSizeUpdate(Size size) {
    if (!mounted) return;
    if (_measuredSize != size || _measuredAvailableWidth != _availableWidth) {
      setState(() {
        _measuredSize = size;
        _measuredAvailableWidth = _availableWidth;
      });
    }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        _availableWidth = constraints.maxWidth;
        // Native measures against the width it's laid out with, so after the offered width changed (for example
        // on rotation) the component gets the whole width again until native reports its new size.
        final measuredSize = _measuredSize;
        final isMeasurementCurrent = measuredSize != null && _measuredAvailableWidth == constraints.maxWidth;
        if (isMeasurementCurrent || constraints.hasBoundedWidth) {
          return _MeasuredSizeBox(
            width: isMeasurementCurrent ? measuredSize.width : null,
            height: measuredSize?.height,
            child: platformView,
          );
        }
        // Without a width limit, for example in a Row, the component takes no width until native reports its size,
        // which it measures within the screen width.
        return _MeasuredSizeBox(
          width: 0,
          height: measuredSize?.height,
          layoutWidth: MediaQuery.sizeOf(context).width,
          child: platformView,
        );
      },
    );
  }

  @override
  void dispose() {
    if (_platformViewId != null && widget.selfSizing) {
      _ComponentSizeDispatcher.instance.unregister(_platformViewId!);
    }
    if (_platformViewId != null) {
      _ComponentTapDispatcher.instance.unregister(_platformViewId!);
      _ScreenDismissDispatcher.instance.unregister(_platformViewId!);
    }
    super.dispose();
  }
}

/// Wraps a self-sizing platform view in a [SizedBox] sized to the native
/// component's reported intrinsic size. Falls back to a 1px height while
/// awaiting the first measurement so the platform view has bounded
/// constraints to lay out against (otherwise unbounded parents like
/// [ListView] would crash). A reported height of 0 collapses the box.
///
/// The widgets around [child] are the same in every case, as a changed
/// structure would recreate the native view.
///
class _MeasuredSizeBox extends StatelessWidget {
  const _MeasuredSizeBox({
    required this.width,
    required this.height,
    this.layoutWidth,
    required this.child,
  });

  /// Width taken in the parent: the measured width, or `null` for the parent's width.
  final double? width;

  /// Measured height, or `null` before the first measurement.
  final double? height;

  /// Width the platform view is laid out with when it differs from [width].
  final double? layoutWidth;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // An empty component takes no space, but the platform view keeps a 1px
    // height so native can still lay it out and report when content appears.
    final isEmpty = height == 0;
    final layoutHeight = isEmpty ? 1.0 : null;
    return SizedBox(
      // Width: null lets the parent's constraint flow through. Height defaults
      // to 1px before native reports back, which still triggers a layout pass
      // and lets the native size reporter measure the intrinsic height.
      width: width,
      height: height ?? 1,
      child: ClipRect(
        clipBehavior: isEmpty || layoutWidth != null ? Clip.hardEdge : Clip.none,
        child: OverflowBox(
          alignment: AlignmentDirectional.topStart,
          minWidth: layoutWidth,
          maxWidth: layoutWidth,
          minHeight: layoutHeight,
          maxHeight: layoutHeight,
          child: child,
        ),
      ),
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

/// Routes native component taps to the registered [IaSdkPlatformView.onTap].
///
/// Listens on the main SDK MethodChannel via the shared [IaBaseCallbacks]
/// system, like [_ComponentSizeDispatcher].
///
class _ComponentTapDispatcher implements IaBaseCallbackHandler {
  _ComponentTapDispatcher._() {
    IaBaseCallbacks(handlers: [this]);
  }

  static final instance = _ComponentTapDispatcher._();

  final _listeners = <int, VoidCallback>{};

  void register(int viewId, VoidCallback callback) {
    _listeners[viewId] = callback;
  }

  void unregister(int viewId) {
    _listeners.remove(viewId);
  }

  @override
  String get methodId => 'componentTapped';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      if (args is! Map) return null;
      final viewId = (args['viewId'] as num).toInt();
      _listeners[viewId]?.call();
      return null;
    };
  }
}

/// Routes the dismiss of an embedded SDK screen to the registered [IaSdkPlatformView.onDismiss].
///
/// Listens on the main SDK MethodChannel via the shared [IaBaseCallbacks]
/// system, like [_ComponentTapDispatcher].
///
class _ScreenDismissDispatcher implements IaBaseCallbackHandler {
  _ScreenDismissDispatcher._() {
    IaBaseCallbacks(handlers: [this]);
  }

  static final instance = _ScreenDismissDispatcher._();

  final _listeners = <int, VoidCallback>{};

  void register(int viewId, VoidCallback callback) {
    _listeners[viewId] = callback;
  }

  void unregister(int viewId) {
    _listeners.remove(viewId);
  }

  @override
  String get methodId => 'screenDismissed';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      if (args is! Map) return null;
      final viewId = (args['viewId'] as num).toInt();
      _listeners[viewId]?.call();
      return null;
    };
  }
}
