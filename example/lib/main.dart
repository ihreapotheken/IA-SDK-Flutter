import 'dart:convert';
import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/ia_client_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(
    IaSdk(
      child: ExampleApp(),
      configuration: ExampleAppConfig.instance.pluginConfig,
    ),
  );
}

class ExampleApp extends StatefulWidget {
  ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  IaSdkApi? get _iaSdk {
    return IaSdk.of(context);
  }

  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: switch (_selectedTabIndex) {
                0 => _ExampleMapView(iaSdk: _iaSdk),
                1 => ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    24 + MediaQuery.of(context).padding.top,
                    20,
                    24,
                  ),
                  children: [
                    ElevatedButton(
                      child: Text('Clear Cart'),
                      onPressed: () async {
                        await _iaSdk?.clearCart();
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Set guest user data'),
                      onPressed: () async {
                        await _iaSdk?.setGuestUserData(
                          salutation: 'Herr',
                          firstName: 'First',
                          lastName: 'Last',
                          email: 'email@example.org',
                          phoneNumberCountryCode: 49,
                          phoneNumberWithoutCountryCode: 432432243,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Logout'),
                      onPressed: () async {
                        await _iaSdk?.logout();
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Transfer prescriptions'),
                      onPressed: () async {
                        try {
                          await _iaSdk?.transferPrescriptions(
                            images: [
                              base64Decode(ExampleAppConfig.instance.mockPngPrescription),
                              base64Decode(ExampleAppConfig.instance.mockJpgPrescription),
                            ],
                            pdfs: [
                              base64Decode(
                                ExampleAppConfig.instance.mockPdfPrescription,
                              ),
                            ],
                            codes: [
                              '{"urls":["Task/test9ba2fee0d07e4ef2b6205f8012e1445b/\$accept?ac=5e24cc059ff244bdbb01efcccf834a6329bdac67a4a64733938fe1b799ac19a9"]}',
                            ],
                            orderId: 'aaaa',
                          );
                        } catch (e) {
                          debugPrint('ERROR TRANSFER');
                          debugPrint('$e', wrapWidth: 999999999999);
                        }
                      },
                    ),
                  ],
                ),
                _ => throw UnimplementedError('Tab view not defined for index #$_selectedTabIndex.'),
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(border: Border(top: BorderSide())),
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
                child: Row(
                  children: [
                    for (final navigationButton in <({String label, IconData icon})>{
                      (
                        label: 'Host App',
                        icon: Icons.home,
                      ),
                      (
                        label: 'AppSDK Services',
                        icon: Icons.category,
                      ),
                    }.indexed)
                      Expanded(
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                Icon(
                                  navigationButton.$2.icon,
                                  color: _selectedTabIndex == navigationButton.$1 ? Theme.of(context).primaryColor : null,
                                ),
                                Text(
                                  navigationButton.$2.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _selectedTabIndex == navigationButton.$1 ? Theme.of(context).primaryColor : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = navigationButton.$1;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleMapView extends StatefulWidget {
  const _ExampleMapView({
    required IaSdkApi? iaSdk,
  }) : _iaSdk = iaSdk;

  final IaSdkApi? _iaSdk;

  @override
  State<_ExampleMapView> createState() => _ExampleMapViewState();
}

class _ExampleMapViewState extends State<_ExampleMapView> {
  late Future<void>? _initIaSdk;

  @override
  void initState() {
    super.initState();
    widget._iaSdk?.configureFooter(shouldShowDataProcessing: false, shouldShowAppSettings: true, shouldShowImprint: true);
    _initIaSdk = widget._iaSdk?.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initIaSdk,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print('AAAAA\n${snapshot.error}');
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        }

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
                for (final marker in <({LatLng point, String pharmacyId})>{
                  (
                    point: LatLng(52.52, 13.4050),
                    pharmacyId: '2163',
                  ),
                  (
                    point: LatLng(52.545095, 13.447899),
                    pharmacyId: '117988',
                  ),
                })
                  Marker(
                    point: marker.point,
                    width: 60,
                    height: 60,
                    child: InkWell(
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
                      onTap: () {
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
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await widget._iaSdk?.setPharmacyId(marker.pharmacyId);

                                            if (Platform.isIOS) {
                                              await Future.delayed(const Duration(seconds: 1));
                                            }
                                            await widget._iaSdk?.launchDashboardRoute();
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
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
