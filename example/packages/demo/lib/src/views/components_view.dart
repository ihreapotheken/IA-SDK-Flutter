import 'package:flutter/material.dart';
import 'package:ia_example_shared/ia_example_shared.dart';
import 'package:ia_interface/ia_interface.dart';
import 'package:ia_ordering/ia_ordering.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';

/// The SDK's widgets a host app embeds in its own screens: the cart button and the product grids.
///
class ComponentsView extends StatefulWidget {
  const ComponentsView({super.key});

  @override
  State<ComponentsView> createState() => _ComponentsViewState();
}

class _ComponentsViewState extends State<ComponentsView> {
  IaProductDisplayType _selectedGridType = IaProductDisplayType.currentOffers;

  final _customPznsController = TextEditingController();

  final _recommendationPznController = TextEditingController();

  List<String> _customPzns = const [];

  bool get _needsPzn {
    return _selectedGridType == IaProductDisplayType.productRecommendations ||
        _selectedGridType == IaProductDisplayType.customersAlsoBought;
  }

  @override
  Widget build(BuildContext context) {
    return IaTabListView(
      children: [
        IaSection(
          title: 'Cart button',
          children: [
            const _LabelledBlock(label: 'The SDK opens the cart', child: IaCartButton()),
            _LabelledBlock(
              label: 'With a host tap handler',
              child: IaCartButton(onTap: () => showIaToast(context, 'Cart button tapped, the host app handles it.')),
            ),
            const _LabelledBlock(
              label: 'In a row, with a set width and height for Android',
              // Taller than the button, as the iOS one draws beyond the size it's given.
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Text('Your cart', style: IaTextStyles.body),
                    SizedBox(width: IaSpacing.md),
                    SizedBox(height: 30, width: 30, child: IaCartButton()),
                  ],
                ),
              ),
            ),
          ],
        ),
        IaSection(
          title: 'Product grid',
          children: [
            IaChoiceRow(
              title: 'Display type',
              options: [
                for (final type in IaProductDisplayType.values)
                  if (type != IaProductDisplayType.custom) (value: type, label: type.name),
              ],
              selected: _selectedGridType,
              onSelected: (type) => setState(() => _selectedGridType = type),
            ),
            if (_needsPzn)
              IaBlock(
                child: IaTextField(
                  label: 'PZN the recommendations are based on',
                  controller: _recommendationPznController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
            if (!_needsPzn || _recommendationPznController.text.trim().isNotEmpty)
              IaBlock(
                child: IaProductGrid(
                  type: _selectedGridType,
                  pzn: _needsPzn ? _recommendationPznController.text.trim() : null,
                ),
              ),
          ],
        ),
        IaSection(
          title: 'Custom product grid',
          children: [
            IaBlock(
              child: IaTextField(
                label: 'PZNs, comma separated',
                controller: _customPznsController,
                onSubmitted: (value) {
                  setState(() {
                    _customPzns = value.split(',').map((pzn) => pzn.trim()).where((pzn) => pzn.isNotEmpty).toList();
                  });
                },
              ),
            ),
            if (_customPzns.isNotEmpty)
              IaBlock(
                child: IaProductGrid(
                  type: IaProductDisplayType.custom,
                  title: 'Selected for you',
                  pzns: _customPzns,
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _customPznsController.dispose();
    _recommendationPznController.dispose();
    super.dispose();
  }
}

/// A component in a section, with a caption above it.
///
class _LabelledBlock extends StatelessWidget {
  const _LabelledBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IaBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: IaSpacing.sm,
        children: [
          Text(label, style: IaTextStyles.caption),
          child,
        ],
      ),
    );
  }
}
