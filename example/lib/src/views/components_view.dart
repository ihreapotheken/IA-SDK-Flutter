import 'package:flutter/material.dart';
import 'package:ia_interface/ia_interface.dart';
import 'package:ia_ordering/ia_ordering.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';

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
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        24 + MediaQuery.of(context).padding.top,
        20,
        24,
      ),
      children: [
        const _SectionHeader('Cart Button'),
        const IaCartButton(),
        const SizedBox(height: 12),
        Text('With a host tap handler', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        IaCartButton(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cart button tapped, the host app handles it.')),
            );
          },
        ),
        const SizedBox(height: 12),
        Text('In a row, with a set width for Android', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        const Row(
          children: [
            Text('Your cart'),
            SizedBox(width: 12),
            SizedBox(width: 64, child: IaCartButton()),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionHeader('Product Grid'),
        Text('Display Type', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: IaProductDisplayType.values.where((type) => type != IaProductDisplayType.custom).map((type) {
            return ChoiceChip(
              label: Text(type.name),
              selected: _selectedGridType == type,
              onSelected: (_) => setState(() => _selectedGridType = type),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (_needsPzn) ...[
          TextField(
            controller: _recommendationPznController,
            decoration: const InputDecoration(labelText: 'PZN the recommendations are based on'),
            onSubmitted: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
        ],
        if (!_needsPzn || _recommendationPznController.text.trim().isNotEmpty)
          IaProductGrid(
            type: _selectedGridType,
            pzn: _needsPzn ? _recommendationPznController.text.trim() : null,
          ),
        const SizedBox(height: 24),
        const _SectionHeader('Custom Product Grid'),
        TextField(
          controller: _customPznsController,
          decoration: const InputDecoration(
            labelText: 'PZNs, comma separated',
          ),
          onSubmitted: (value) {
            setState(() {
              _customPzns = value.split(',').map((pzn) => pzn.trim()).where((pzn) => pzn.isNotEmpty).toList();
            });
          },
        ),
        const SizedBox(height: 12),
        if (_customPzns.isNotEmpty)
          IaProductGrid(
            type: IaProductDisplayType.custom,
            title: 'Selected for you',
            pzns: _customPzns,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
