import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ia_example_shared/src/ui/tappable.dart';
import 'package:ia_example_shared/src/ui/theme.dart';

/// A titled card of rows and blocks, with hairlines between them. Rows for another platform, see
/// [IaPlatformSpecific], are left out.
///
class IaSection extends StatelessWidget {
  const IaSection({super.key, required this.title, this.trailing, required this.children});

  final String title;

  /// Beside the title, e.g. an [IaLinkButton].
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final shownChildren = [
      for (final child in children)
        if (child is! IaPlatformSpecific || (child as IaPlatformSpecific).isShownHere) child,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(IaSpacing.xs, IaSpacing.xl, 0, IaSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text(title.toUpperCase(), style: IaTextStyles.overline)),
              ?trailing,
            ],
          ),
        ),
        IaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, child) in shownChildren.indexed) ...[
                if (index > 0) const IaDivider(),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A widget, usually a row, for an API only one native SDK has. It shows only on its [platform], and an [IaSection]
/// leaves it out on the other.
///
abstract interface class IaPlatformSpecific {
  /// `null` when it's on both.
  IaPlatform? get platform;
}

extension IaPlatformSpecificVisibility on IaPlatformSpecific {
  bool get isShownHere => platform?.isCurrent ?? true;
}

/// The platform an API exists on, for a row of an API only one native SDK has.
///
enum IaPlatform {
  ios('iOS'),
  android('Android');

  const IaPlatform(this.label);

  final String label;

  bool get isCurrent => this == (Platform.isIOS ? ios : android);
}

/// The hairline between the rows of a section.
///
class IaDivider extends StatelessWidget {
  const IaDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1 / MediaQuery.devicePixelRatioOf(context), color: IaColors.border);
  }
}

/// A white rounded card with the soft shadow.
///
class IaCard extends StatelessWidget {
  const IaCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: IaColors.surface,
        borderRadius: BorderRadius.circular(IaRadius.lg),
        boxShadow: iaCardShadow,
      ),
      child: child,
    );
  }
}

/// Content in an [IaSection] that isn't a row, e.g. a hint, chips or a text field.
///
class IaBlock extends StatelessWidget {
  const IaBlock({super.key, this.padding = const EdgeInsets.all(IaSpacing.lg), required this.child});

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// An explanation in a section.
///
class IaHint extends StatelessWidget {
  const IaHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IaBlock(child: Text(text, style: IaTextStyles.caption));
  }
}

/// A note at the top of a tab, e.g. that its calls need the SDK initialized.
///
class IaNotice extends StatelessWidget {
  const IaNotice(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: IaSpacing.lg),
      padding: const EdgeInsets.all(IaSpacing.md),
      decoration: BoxDecoration(color: IaColors.accentSoft, borderRadius: BorderRadius.circular(IaRadius.md)),
      child: Text(text, style: IaTextStyles.caption.copyWith(color: IaColors.accentOnSoft)),
    );
  }
}

/// A small text button, e.g. beside a section title.
///
class IaLinkButton extends StatelessWidget {
  const IaLinkButton({super.key, required this.title, required this.onTap});

  final String title;

  /// `null` disables it.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IaTappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(IaSpacing.xs, IaSpacing.xs, IaSpacing.xs, IaSpacing.xs + 2),
        child: Text(
          title,
          style: IaTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: IaColors.accent),
        ),
      ),
    );
  }
}

/// A tab's scrolling content, usually [IaSection]s.
///
class IaTabListView extends StatelessWidget {
  const IaTabListView({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(IaSpacing.lg, 0, IaSpacing.lg, IaSpacing.xxl),
      children: children,
    );
  }
}
