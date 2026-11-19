import 'dart:async';

import 'package:flutter/widgets.dart';

/// Dims its child while pressed, like the React Native example's rows and buttons. A disabled one, with no [onTap],
/// is dimmed.
///
class IaTappable extends StatefulWidget {
  const IaTappable({super.key, required this.onTap, required this.child, this.isDimmedWhenDisabled = true});

  final VoidCallback? onTap;
  final Widget child;

  /// `false` keeps a disabled one opaque, e.g. a busy row that shows its progress.
  final bool isDimmedWhenDisabled;

  @override
  State<IaTappable> createState() => _IaTappableState();
}

class _IaTappableState extends State<IaTappable> {
  bool _isPressed = false;

  void _setPressed(bool isPressed) {
    if (_isPressed != isPressed) setState(() => _isPressed = isPressed);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    final opacity = !isEnabled
        ? (widget.isDimmedWhenDisabled ? 0.45 : 1.0)
        : _isPressed
        ? 0.7
        : 1.0;
    return Semantics(
      button: true,
      enabled: isEnabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: isEnabled ? (_) => _setPressed(true) : null,
        onTapUp: isEnabled ? (_) => _setPressed(false) : null,
        onTapCancel: isEnabled ? () => _setPressed(false) : null,
        child: AnimatedOpacity(opacity: opacity, duration: const Duration(milliseconds: 90), child: widget.child),
      ),
    );
  }
}

/// Tracks whether the action a widget started is still running, so the widget shows progress and ignores taps
/// meanwhile.
///
mixin IaBusyState<T extends StatefulWidget> on State<T> {
  bool isBusy = false;

  /// Runs [action]. If it returns a future, [isBusy] is `true` until the future completes. A failure still reaches
  /// the zone's error handler.
  ///
  void runBusy(FutureOr<void> Function() action) {
    if (isBusy) return;
    final result = action();
    if (result is! Future<void>) return;
    setState(() => isBusy = true);
    unawaited(
      result.whenComplete(() {
        if (mounted) setState(() => isBusy = false);
      }),
    );
  }
}
