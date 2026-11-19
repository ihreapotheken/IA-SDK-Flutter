import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ia_example_shared/src/ui/controls.dart';
import 'package:ia_example_shared/src/ui/section.dart';
import 'package:ia_example_shared/src/ui/tappable.dart';
import 'package:ia_example_shared/src/ui/theme.dart';

/// A row in an [IaSection] that runs an action. While the future [onTap] returns is pending, the row shows a spinner
/// and takes no taps. A row for one [platform] shows its badge there and isn't shown on the other.
///
class IaActionRow extends StatefulWidget implements IaPlatformSpecific {
  const IaActionRow({
    super.key,
    required this.title,
    this.description,
    this.platform,
    this.isDestructive = false,
    required this.onTap,
  });

  final String title;
  final String? description;
  @override
  final IaPlatform? platform;

  /// Returns a future to show progress until it completes. `null` disables the row.
  final FutureOr<void> Function()? onTap;

  /// Red, for an action that deletes data.
  final bool isDestructive;

  @override
  State<IaActionRow> createState() => _IaActionRowState();
}

class _IaActionRowState extends State<IaActionRow> with IaBusyState {
  @override
  Widget build(BuildContext context) {
    if (!widget.isShownHere) return const SizedBox.shrink();
    final onTap = widget.onTap;
    return IaTappable(
      onTap: onTap == null || isBusy ? null : () => runBusy(onTap),
      isDimmedWhenDisabled: !isBusy,
      child: IaBlock(
        padding: _rowPadding,
        child: Row(
          children: [
            Expanded(
              child: _RowText(
                title: widget.title,
                description: widget.description,
                platform: widget.platform,
                titleColor: widget.isDestructive ? IaColors.accentOnSoft : null,
              ),
            ),
            const SizedBox(width: IaSpacing.md),
            SizedBox(
              width: 24,
              child: Center(
                child: isBusy
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.4))
                    : const Icon(Icons.chevron_right_rounded, color: IaColors.inkTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row in an [IaSection] with a switch.
///
class IaSwitchRow extends StatelessWidget implements IaPlatformSpecific {
  const IaSwitchRow({super.key, required this.title, this.description, this.platform, required this.value, required this.onChanged});

  final String title;
  final String? description;
  @override
  final IaPlatform? platform;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!isShownHere) return const SizedBox.shrink();
    return IaBlock(
      padding: const EdgeInsets.fromLTRB(IaSpacing.lg, IaSpacing.sm, IaSpacing.md, IaSpacing.sm),
      child: MergeSemantics(
        child: Row(
          children: [
            Expanded(
              child: _RowText(title: title, description: description, platform: platform),
            ),
            const SizedBox(width: IaSpacing.md),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: IaColors.accent,
              inactiveTrackColor: IaColors.switchOff,
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row in an [IaSection] that shows a value, e.g. a setting the row edits when tapped.
///
class IaValueRow extends StatelessWidget implements IaPlatformSpecific {
  const IaValueRow({super.key, required this.title, required this.value, this.platform, required this.onTap});

  final String title;
  final String value;
  @override
  final IaPlatform? platform;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!isShownHere) return const SizedBox.shrink();
    return IaTappable(
      onTap: onTap,
      child: IaBlock(
        padding: _rowPadding,
        child: Row(
          children: [
            Expanded(
              child: _RowText(title: title, description: value, platform: platform),
            ),
            const SizedBox(width: IaSpacing.md),
            const Icon(Icons.edit_outlined, size: 20, color: IaColors.inkTertiary),
          ],
        ),
      ),
    );
  }
}

/// A row in an [IaSection] with a choice of one option, as chips, and a [note] below them.
///
class IaChoiceRow<T> extends StatelessWidget implements IaPlatformSpecific {
  const IaChoiceRow({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.note,
    this.platform,
  });

  final String title;
  final List<({T value, String label})> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final String? note;
  @override
  final IaPlatform? platform;

  @override
  Widget build(BuildContext context) {
    if (!isShownHere) return const SizedBox.shrink();
    final note = this.note;
    return IaBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RowText(title: title, platform: platform),
          const SizedBox(height: IaSpacing.md),
          IaChoiceChips(options: options, selected: selected, onSelected: onSelected),
          if (note != null) ...[
            const SizedBox(height: IaSpacing.sm),
            Text(note, style: IaTextStyles.caption),
          ],
        ],
      ),
    );
  }
}

const _rowPadding = EdgeInsets.symmetric(horizontal: IaSpacing.lg, vertical: IaSpacing.md + 2);

class _RowText extends StatelessWidget {
  const _RowText({required this.title, this.description, this.platform, this.titleColor});

  final String title;
  final String? description;
  final IaPlatform? platform;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final platform = this.platform;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: title,
            children: [
              if (platform != null) ...[
                const TextSpan(text: ' '),
                WidgetSpan(alignment: PlaceholderAlignment.middle, child: _PlatformBadge(platform)),
              ],
            ],
          ),
          style: IaTextStyles.headline.copyWith(fontSize: 15, color: titleColor),
        ),
        if (description != null) ...[
          const SizedBox(height: 2),
          Text(description, style: IaTextStyles.caption),
        ],
      ],
    );
  }
}

/// Marks a row whose API exists on one platform only.
///
class _PlatformBadge extends StatelessWidget {
  const _PlatformBadge(this.platform);

  final IaPlatform platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: IaColors.surfaceSunken, borderRadius: BorderRadius.circular(IaRadius.pill)),
      child: Text(
        platform.label,
        style: const TextStyle(
          fontSize: 10,
          height: 14 / 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: IaColors.inkSecondary,
        ),
      ),
    );
  }
}
