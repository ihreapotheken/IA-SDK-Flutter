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
        const SizedBox(height: 24),
        const _SectionHeader('Product Grid'),
        Text('Display Type', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: IaProductDisplayType.values.map((type) {
            return ChoiceChip(
              label: Text(type.name),
              selected: _selectedGridType == type,
              onSelected: (_) => setState(() => _selectedGridType = type),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        IaProductGrid(
          key: ValueKey(_selectedGridType),
          type: _selectedGridType,
        ),
      ],
    );
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
