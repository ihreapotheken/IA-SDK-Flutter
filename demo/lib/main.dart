import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  final methodChannel = const MethodChannel('de.ihreapotheken/sdk');

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
              ElevatedButton(
                child: Text('Init ia.de SDK'),
                onPressed: () async {
                  await methodChannel.invokeMethod('initIaSdk');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
