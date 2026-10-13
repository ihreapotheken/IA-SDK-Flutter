import 'package:flutter/widgets.dart';
import 'package:ia_interface/ia_interface.dart';

/// Inline native product grid component.
///
class IaProductGrid extends StatelessWidget {
  /// Default constructor for [IaProductGrid].
  ///
  const IaProductGrid({
    super.key,
    required this.type,
    this.pzn,
    this.shouldShowLoading = true,
    this.title,
    this.pzns,
  }) : assert(type != IaProductDisplayType.custom || pzns != null, 'The custom type needs pzns.');

  /// Product collection to display.
  ///
  final IaProductDisplayType type;

  /// Product identifier (pzn) the recommendation-based types are based on. Without one they show no products.
  ///
  /// For [IaProductDisplayType.currentOffers] and [IaProductDisplayType.productsOfTheMonth], iOS leaves this
  /// product out of the grid. Android ignores it for those types.
  ///
  final String? pzn;

  /// Whether to show a loading indicator while products load.
  ///
  final bool shouldShowLoading;

  /// Title of the grid, for [IaProductDisplayType.custom].
  ///
  final String? title;

  /// Product identifiers (pzns) to show, for [IaProductDisplayType.custom].
  ///
  final List<String>? pzns;

  @override
  Widget build(BuildContext context) {
    return IaSdkPlatformView(
      viewId: 'productGrid',
      creationParams: {
        'type': type.name,
        if (pzn != null) 'pzn': pzn,
        'shouldShowLoading': shouldShowLoading,
        if (title != null) 'title': title,
        if (pzns != null) 'pzns': pzns,
      },
    );
  }
}
