import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/ia_client_config.dart';
import 'package:flutter/material.dart';
import 'package:ia_cardlink/ia_cardlink.dart';
import 'package:ia_ordering/ia_ordering.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';
import 'package:ia_pharmacy/ia_pharmacy.dart';
import 'package:ia_prescription/ia_prescription.dart';

/// Minimal E2E smoke entry, enabled with `--dart-define=iaE2E=true`.
///
/// It only verifies what a cross-platform integration test needs: the app
/// launches without crashing, and `IaSdk.initialize()` completes successfully.
/// On success it shows a stable "SDK initialized" marker; on failure it shows
/// the error. The E2E test launches the app and asserts the success marker.
class E2eSmokeApp extends StatelessWidget {
  const E2eSmokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _E2eSmoke(),
    );
  }
}

class _E2eSmoke extends StatefulWidget {
  const _E2eSmoke();

  @override
  State<_E2eSmoke> createState() => _E2eSmokeState();
}

class _E2eSmokeState extends State<_E2eSmoke> {
  late final Future<void> _init = _initializeSdk();

  Future<void> _initializeSdk() async {
    await IaSdk.instance.register(
      modules: [
        IaModuleCardLink(),
        IaModuleOrdering(),
        IaModuleOverTheCounter(),
        IaModulePharmacy(),
        IaModulePrescription(),
      ],
    );
    await IaSdk.instance.initialize(
      config: ExampleAppConfig.instance.pluginConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<void>(
          future: _init,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Semantics(
                identifier: 'sdk_init_error',
                child: Text(
                  'SDK init failed: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Semantics(
              identifier: 'sdk_init_ok',
              child: const Text('SDK initialized'),
            );
          },
        ),
      ),
    );
  }
}
