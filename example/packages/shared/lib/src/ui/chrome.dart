import 'package:flutter/material.dart';
import 'package:ia_example_shared/src/ui/tappable.dart';
import 'package:ia_example_shared/src/ui/theme.dart';

/// The top of an example app: the ia.de mark and the app's name, a status, e.g. an [IaStatusPill], and a line below,
/// e.g. the platform, SDK version and backend.
///
class IaBrandHeader extends StatelessWidget {
  const IaBrandHeader({super.key, required this.product, this.status, this.subtitle});

  final String product;
  final Widget? status;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Padding(
      padding: EdgeInsets.fromLTRB(IaSpacing.lg, MediaQuery.paddingOf(context).top + IaSpacing.md, IaSpacing.lg, IaSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  spacing: IaSpacing.sm,
                  children: [
                    const Text(
                      'ia.de',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: IaColors.accent),
                    ),
                    Flexible(
                      child: Text(
                        product,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: IaTextStyles.headline.copyWith(color: IaColors.inkSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              ?status,
            ],
          ),
          if (subtitle != null) Text(subtitle, style: IaTextStyles.caption.copyWith(color: IaColors.inkTertiary)),
        ],
      ),
    );
  }
}

/// A state, e.g. whether the SDK is initialized, as a pill with a dot: green when [isReady].
///
class IaStatusPill extends StatelessWidget {
  const IaStatusPill({super.key, required this.label, required this.isReady});

  final String label;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final color = isReady ? IaColors.success : IaColors.inkSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: IaSpacing.md, vertical: IaSpacing.xs),
      decoration: BoxDecoration(
        color: isReady ? IaColors.successSoft : IaColors.surfaceSunken,
        borderRadius: BorderRadius.circular(IaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: isReady ? IaColors.success : IaColors.inkTertiary, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: IaTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

/// The tabs at the bottom of an example app. The selected one is red, with a bar above it.
///
class IaTabBar extends StatelessWidget {
  const IaTabBar({super.key, required this.tabs, required this.selectedIndex, required this.onSelected});

  final List<({String label, IconData icon})> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: IaColors.surface,
        border: Border(top: BorderSide(color: IaColors.border, width: 0)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : IaSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, tab) in tabs.indexed)
              Expanded(
                child: _Tab(label: tab.label, icon: tab.icon, isSelected: index == selectedIndex, onTap: () => onSelected(index)),
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.icon, required this.isSelected, required this.onTap});

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? IaColors.accent : IaColors.inkSecondary;
    return Semantics(
      selected: isSelected,
      child: IaTappable(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: IaSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? IaColors.accent : null,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
              ),
            ),
            const SizedBox(height: IaSpacing.sm),
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: IaTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: color,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: IaSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// Shows [message] in a dark pill at the bottom, replacing the one shown.
///
void showIaToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(seconds: 3),
      ),
    );
}
