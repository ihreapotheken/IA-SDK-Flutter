import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:latlong2/latlong.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _pharmacyMarkers = <({LatLng point, String pharmacyId})>[
    (point: LatLng(52.52, 13.4050), pharmacyId: '2163'),
    (point: LatLng(52.545095, 13.447899), pharmacyId: '117988'),
  ];

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
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
                width: 60,
                height: 60,
                child: _PharmacyMarker(
                  pharmacyId: marker.pharmacyId,
                ),
              ),
          ],
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
    return InkWell(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Icon(
            Icons.local_pharmacy,
            color: Colors.red,
          ),
        ),
      ),
      onTap: () => _showPharmacyBottomSheet(context),
    );
  }

  void _showPharmacyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          showDragHandle: true,
          backgroundColor: Colors.white,
          elevation: 16,
          builder: (context) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                20 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: FilledButton(
                      child: const Text('Online Shopping'),
                      onPressed: () => _onOnlineShoppingPressed(context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onOnlineShoppingPressed(BuildContext context) async {
    Navigator.pop(context);
    await IaSdk.instance.pharmacy.setPharmacyId(pharmacyId);
    await IaSdk.instance.launchStartRoute();
    if (Platform.isIOS) {
      await Future.delayed(const Duration(seconds: 1));
    }
    await FlutterWebBrowser.openWebPage(
      url: 'https://example.org/',
      customTabsOptions: const CustomTabsOptions(
        colorScheme: CustomTabsColorScheme.dark,
        shareState: CustomTabsShareState.on,
        instantAppsEnabled: true,
        showTitle: true,
        urlBarHidingEnabled: true,
      ),
      safariVCOptions: const SafariViewControllerOptions(
        barCollapsingEnabled: true,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        modalPresentationCapturesStatusBarAppearance: true,
        modalPresentationStyle: UIModalPresentationStyle.fullScreen,
      ),
    );
  }
}
