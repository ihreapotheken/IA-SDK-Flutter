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
  });

  /// Product collection to display.
  ///
  final IaProductDisplayType type;

  /// Optional product identifier (pzn) for recommendation-based types.
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
