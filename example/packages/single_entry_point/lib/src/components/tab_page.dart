import 'package:flutter/material.dart';
import 'package:ia_example_shared/ia_example_shared.dart';

/// A tab of the host app: its title, and its content in a card.
///
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(IaSpacing.lg, MediaQuery.paddingOf(context).top + IaSpacing.md, IaSpacing.lg, IaSpacing.sm),
            child: Text(
              title,
              style: const TextStyle(fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: IaColors.ink),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(IaSpacing.lg),
                child: IaCard(
                  child: Padding(
                    padding: const EdgeInsets.all(IaSpacing.xl),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
