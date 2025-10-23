import 'dart:convert';
import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/ia_client_config.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatefulWidget {
  ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _iaSdk = IaSdk(configuration: ExampleAppConfig.instance.pluginConfig);

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
                0 => ListView(
                  padding: EdgeInsets.fromLTRB(20, 24 + MediaQuery.of(context).padding.top, 20, 24),
                  children: [
                    ElevatedButton(
                      child: Text('Init ia.de SDK'),
                      onPressed: () async {
                        await _iaSdk.init();
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Launch dashboard route'),
                      onPressed: () async {
                        await _iaSdk.launchDashboardRoute();
                      },
                    ),
                    const SizedBox(height: 16),
                    Platform.isAndroid
                        ? ElevatedButton(
                            child: Text('Launch legal disclaimer route'),
                            onPressed: () async {
                              await _iaSdk.launchLegalDisclaimerRoute();
                            },
                          )
                        : ElevatedButton(
                            child: Text('Launch product search route'),
                            onPressed: () async {
                              await _iaSdk.launchProductSearchRoute();
                            },
                          ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Transfer prescriptions'),
                      onPressed: () async {
                        const String pngBase64 =
                            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=';
                        const String jpgBase64 =
                            '/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxISEhUTEhIVFhUVFRUVFRUVFRUVFRUVFRUWFhUVFRUYHSggGBolGxUVITEhJSkrLi4uFx8zODMsNygtLisBCgoKDg0OGxAQGy0lICYtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLf/AABEIAKABJwMBIgACEQEDEQH/xAAcAAABBQEBAQAAAAAAAAAAAAAAAQIDBAUGBwj/xAA+EAACAQIDBQcEAwcEAwAAAAABAgADEQQSIQUGEzFBURQiYXGBkbHB0RQjQlJy0fAzcoKS4fEk/8QAGAEBAQEBAQAAAAAAAAAAAAAAAAECAwT/xAAjEQEBAAICAgIDAQAAAAAAAAAAAQIRAyESMQQTIkFRYQUi/9oADAMBAAIRAxEAPwD9+iiigAooooAKKKKACiiigA//2Q==';
                        const String pdfBase64 =
                            'JVBERi0xLjQKJeLjz9MKMSAwIG9iago8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFI+PgplbmRvYmoKMiAwIG9iago8PC9UeXBlL1BhZ2VzL0NvdW50IDAvS2lkc1szIDAgUiBdPj4KZW5kb2JqCjMgMCBvYmoKPDwvVHlwZS9QYWdlL1BhcmVudCAyIDAgUi9SZXNvdXJjZXM8PC9Qcm9jU2V0Wy9QREZdPj4vTWVkaWFCb3hbMCAwIDU5NSA4NDJdPj4KZW5kb2JqCnhyZWYKMCA0CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDExMCAwMDAwMCBuIAowMDAwMDAwMDc1IDAwMDAwIG4gCjAwMDAwMDAxMzAgMDAwMDAgbiAKdHJhaWxlcgo8PC9TaXplIDQvUm9vdCAxIDAgUi9JbmZvIDQgMCBSL0lEIFs8RDY1RkM0M0YyRUQwMEQzNjI3Q0U2NDI3QUQzQkJENUY+Pj4+PgpzdGFydHhyZWYKMTM0CiUlRU9G';
                        await _iaSdk.transferPrescriptions(
                          images: [base64Decode(pngBase64), base64Decode(jpgBase64)],
                          pdfs: [base64Decode(pdfBase64)],
                          codes: [
                            [
                              'Task/test9ba2fee0d07e4ef2b6205f8012e1445b/\$accept?'
                                  'ac=5e24cc059ff244bdbb01efcccf834a6329bdac67a4a64733938fe1b799ac19a9',
                              'Task/test6ffbb0e6a9d449ceb8c168be8d105403/\$accept?'
                                  'ac=b64b434f3a874c0a9bc110205e2d8d8a7283e8cfbd1b496f807fef7cc8299cb3',
                            ],
                            [
                              'Task/test6b7f0170fbc24ec7a467b3d23444f5d9/\$accept?'
                                  'ac=a7c07835565d48138d810f138e685252fa8580ee14ba4594879d6fa426bdb7c8',
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
                1 => IaSdkPlatformView.startScreen(),
                2 => Platform.isAndroid ? IaSdkPlatformView.legalDisclaimerScreen() : IaSdkPlatformView.productSearchScreen(),
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
                      (label: 'Host App', icon: Icons.home),
                      (label: 'AppSDK Start', icon: Icons.category),
                      (
                        label: Platform.isAndroid ? 'AppSDK Legal' : 'AppSDK Product Search',
                        icon: Platform.isAndroid ? Icons.article : Icons.search,
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
