import 'package:flutter/material.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';
import 'package:ia_ordering/ia_ordering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'components/tab_page.dart';

class IaSdkPage extends StatelessWidget {
  const IaSdkPage({super.key});

  Future<void> launchSdk() async {
    IaSdk.instance.register(
      modules: [
        IaModuleOverTheCounter(),
        IaModuleOrdering(),
      ],
    );

    const serverEnvironment = IaSdkConfigurationServerEnvironment.staging;

    var configuration = IaSdkConfiguration(
      accessKey: dotenv.env['API_KEY'] ?? '',
      clientId: '5004',
      serverEnvironment: serverEnvironment,
      shouldFetchThemeFromRemote: false,
      qaConfiguration: serverEnvironment == IaSdkConfigurationServerEnvironment.production
          ? null
          : const IaSdkConfigurationQa(showTestPharmaciesInApofinder: true),
    );

    try {
      await IaSdk.instance.initialize(config: configuration);
      debugPrint('>>> IA-SDK: initialize succeeded');
    } catch (error) {
      debugPrint('>>> IA-SDK: initialize failed: $error');
    }

    await IaSdk.instance.launchStartRoute();
  }

  Future<void> resetPrerequisites() async {
    try {
      await IaSdk.instance.resetPrerequisites();
      debugPrint('>>> IA-SDK: resetPrerequisites succeeded');
    } catch (error) {
      debugPrint('>>> IA-SDK: resetPrerequisites failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabPage(
      title: 'IA SDK',
      child: Column(
        mainAxisSize: .min,
        spacing: 16,
        children: [
          const Text(
            'This screen is the only place from which IA SDK is started.',
            textAlign: .center,
          ),
          FilledButton(onPressed: launchSdk, child: const Text('Launch IA SDK')),
          OutlinedButton(
            onPressed: resetPrerequisites,
            child: const Text('Reset Initialization and prerequisites'),
          ),
        ],
      ),
    );
  }
}
