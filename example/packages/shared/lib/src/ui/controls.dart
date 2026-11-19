import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ia_example_shared/src/ui/tappable.dart';
import 'package:ia_example_shared/src/ui/theme.dart';

enum IaButtonVariant {
  primary(background: IaColors.accent, foreground: Colors.white),
  secondary(background: IaColors.surfaceSunken, foreground: IaColors.ink),
  danger(background: IaColors.accentSoft, foreground: IaColors.accentOnSoft);

  const IaButtonVariant({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

/// A pill button, or a rounder one when its title wraps. While the future [onTap] returns is pending, it shows a spinner instead of its icon and takes no
/// taps.
///
class IaButton extends StatefulWidget {
  const IaButton({
    super.key,
    required this.title,
    required this.onTap,
    this.variant = IaButtonVariant.primary,
    this.icon,
    this.isCompact = false,
  });

  final String title;

  /// Returns a future to show progress until it completes. `null` disables the button.
  final FutureOr<void> Function()? onTap;
  final IaButtonVariant variant;
  final IconData? icon;

  /// Smaller, e.g. beside other buttons in a row.
  final bool isCompact;

  @override
  State<IaButton> createState() => _IaButtonState();
}

class _IaButtonState extends State<IaButton> with IaBusyState {
  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    final color = widget.variant.foreground;
    final icon = widget.icon;
    final isCompact = widget.isCompact;
    final textStyle = isCompact ? IaTextStyles.caption.copyWith(fontWeight: FontWeight.w600) : IaTextStyles.headline;
    return IaTappable(
      onTap: onTap == null || isBusy ? null : () => runBusy(onTap),
      isDimmedWhenDisabled: !isBusy,
      child: Container(
        constraints: BoxConstraints(minHeight: isCompact ? 34 : 48),
        padding: EdgeInsets.symmetric(horizontal: isCompact ? IaSpacing.lg : IaSpacing.xl, vertical: IaSpacing.xs),
        decoration: BoxDecoration(color: widget.variant.background, borderRadius: BorderRadius.circular(IaRadius.pill)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: IaSpacing.sm,
          children: [
            if (isBusy)
              SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: color))
            else if (icon != null)
              Icon(icon, size: 20, color: color),
            Flexible(
              child: Text(
                widget.title,
                // A long title wraps rather than losing its end.
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small selectable pill.
///
class IaChip extends StatelessWidget {
  const IaChip({super.key, required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IaTappable(
      onTap: onTap,
      child: Semantics(
        selected: isSelected,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: IaSpacing.lg, vertical: IaSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? IaColors.accentSoft : IaColors.surfaceSunken,
            border: Border.all(color: isSelected ? IaColors.accent : IaColors.surfaceSunken),
            borderRadius: BorderRadius.circular(IaRadius.pill),
          ),
          child: Text(
            label,
            style: IaTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? IaColors.accentOnSoft : IaColors.inkSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// A choice of one option, as chips that wrap.
///
class IaChoiceChips<T> extends StatelessWidget {
  const IaChoiceChips({super.key, required this.options, required this.selected, required this.onSelected});

  final List<({T value, String label})> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: IaSpacing.sm,
      runSpacing: IaSpacing.sm,
      children: [
        for (final option in options)
          IaChip(label: option.label, isSelected: option.value == selected, onTap: () => onSelected(option.value)),
      ],
    );
  }
}

/// A labelled text input.
///
class IaTextField extends StatelessWidget {
  const IaTextField({
    super.key,
    this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLength,
    this.onSubmitted,
    this.suffix,
  });

  final String? label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onSubmitted;

  /// E.g. a clear button.
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: IaSpacing.xs,
      children: [
        if (label != null) Text(label, style: IaTextStyles.caption),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          onSubmitted: onSubmitted,
          style: IaTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffix,
            // The length shows in the hint instead.
            counterText: '',
          ),
        ),
      ],
    );
  }
}
