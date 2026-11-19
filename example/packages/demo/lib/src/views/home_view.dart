import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ia_example_shared/ia_example_shared.dart';
import 'package:latlong2/latlong.dart';

/// A host app's own screen, a map of pharmacies, from which it opens the SDK with the pharmacy a user picks.
///
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _pharmacyMarkers = <({LatLng point, String pharmacyId})>[
    (point: LatLng(52.52, 13.4050), pharmacyId: '2163'),
    (point: LatLng(52.545095, 13.447899), pharmacyId: '117988'),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(52.52, 13.4050),
            initialZoom: 9.2,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'de.ihreapotheken.sdk',
            ),
            MarkerLayer(
              markers: [
                for (final marker in _pharmacyMarkers)
                  Marker(
                    point: marker.point,
                    width: 48,
                    height: 48,
                    child: _PharmacyMarker(pharmacyId: marker.pharmacyId),
                  ),
              ],
            ),
          ],
        ),
        const Positioned(
          left: IaSpacing.lg,
          right: IaSpacing.lg,
          top: IaSpacing.sm,
          child: IaCard(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: IaSpacing.lg, vertical: IaSpacing.md),
              child: Row(
                spacing: IaSpacing.md,
                children: [
                  Icon(Icons.touch_app_outlined, color: IaColors.accent),
                  Expanded(
                    child: Text('Tap a pharmacy to shop there with the SDK.', style: IaTextStyles.caption),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PharmacyMarker extends StatelessWidget {
  const _PharmacyMarker({
    required this.pharmacyId,
  });

  final String pharmacyId;

  @override
  Widget build(BuildContext context) {
    return IaTappable(
      onTap: () => _showPharmacySheet(context),
      child: const DecoratedBox(
        decoration: BoxDecoration(color: IaColors.surface, shape: BoxShape.circle, boxShadow: iaCardShadow),
        child: Center(child: Icon(Icons.local_pharmacy_rounded, color: IaColors.accent)),
      ),
    );
  }

  void _showPharmacySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _PharmacySheet(pharmacyId: pharmacyId),
    );
  }
}

/// The pharmacy a marker stands for, with a button that selects it and opens the SDK.
///
class _PharmacySheet extends StatelessWidget {
  const _PharmacySheet({required this.pharmacyId});

  final String pharmacyId;

  Future<void> _shopOnline(BuildContext context) async {
    try {
      await IaSdk.instance.pharmacy.setPharmacyId(pharmacyId);
      await IaSdk.instance.launchStartRoute();
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) showIaToast(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(IaSpacing.xl, 0, IaSpacing.xl, IaSpacing.xl + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Pharmacy $pharmacyId', style: IaTextStyles.title),
          const SizedBox(height: IaSpacing.xs),
          const Text(
            'Shopping online selects this pharmacy and opens the SDK, with its products, prescriptions and checkout.',
            style: IaTextStyles.caption,
          ),
          const SizedBox(height: IaSpacing.xl),
          IaButton(title: 'Online Shopping', icon: Icons.shopping_bag_outlined, onTap: () => _shopOnline(context)),
        ],
      ),
    );
  }
}
