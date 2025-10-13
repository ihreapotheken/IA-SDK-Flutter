import 'package:appsdkv2_flutter_plugin_demo/client/config.dart';
import 'package:appsdkv2_flutter_plugin_demo/sdk/sdk.dart';
import 'package:appsdkv2_flutter_plugin_demo/sdk/view.dart';
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
  final _iaSdk = IaSdk(
    configuration: ExampleAppConfig.instance.pluginConfig,
  );

  Key _platformViewKey = UniqueKey();

  int _selectedView = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text('Init ia.de SDK'),
                      onPressed: () async {
                        await _iaSdk.init();
                        setState(() {
                          _platformViewKey = UniqueKey();
                        });
                      },
                    ),
                    ElevatedButton(
                      child: Text('Show product search'),
                      onPressed: () {
                        setState(() {
                          _selectedView = 0;
                        });
                      },
                    ),
                    ElevatedButton(
                      child: Text('Show cart screen'),
                      onPressed: () {
                        setState(() {
                          _selectedView = 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox.expand(
                  child: switch (_selectedView) {
                    0 => IaSdkPlatformView.productSearch(
                      key: _platformViewKey,
                    ),
                    1 => IaSdkPlatformView.cartScreen(
                      key: _platformViewKey,
                    ),
                    _ => throw UnimplementedError(),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
