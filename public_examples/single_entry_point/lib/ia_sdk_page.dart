import 'package:flutter/material.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';
import 'package:ia_ordering/ia_ordering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'components/tab_page.dart';

class IaSdkPage extends StatelessWidget {
  const IaSdkPage({super.key});

  void showMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> launchSdk(BuildContext context) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    IaSdk.instance.register(
      modules: [
        IaModuleOverTheCounter(),
        IaModuleOrdering(),
      ],
    );

    const serverEnvironment = IaSdkConfigurationServerEnvironment.staging;
    var configuration = IaSdkConfiguration(
      /// Example: Put your access key here
      accessKey: dotenv.env['API_KEY'] ?? '',
      /// Example: Put your client id here.
      clientId: '5004',
      serverEnvironment: serverEnvironment,
      shouldFetchThemeFromRemote: false,
      qaConfiguration: serverEnvironment == IaSdkConfigurationServerEnvironment.production
          ? null
          : const IaSdkConfigurationQa(showTestPharmaciesInApofinder: true),
      initialization: IaSdkConfigurationInitialization(
        shouldShowIndicator: true,
        prerequisites: IaPrerequisitesConfiguration(
          isCancellable: true,
          isAnimated: true,
          runLegalIfNeeded: true,
          runOnboardingIfNeeded: true,
          runApofinderIfNeeded: true,
        ),
      ),
    );

    try {
      await IaSdk.instance.initialize(config: configuration);
      var result = await IaSdk.instance.launchPrerequisiteFlow();
      if (!result.isCancelled) {
        await IaSdk.instance.launchStartRoute();
      }
      debugPrint('>>> IA-SDK: initialize succeeded ${result.isCancelled}');
    } catch (error) {
      debugPrint('>>> IA-SDK: initialize failed: $error');
      showMessage(context, 'Initialize failed: $error');
    }
  }

  Future<void> resetPrerequisites(BuildContext context) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    try {
      await IaSdk.instance.resetPrerequisites();
      debugPrint('>>> IA-SDK: resetPrerequisites succeeded');
      showMessage(context, 'Prerequisites reset');
    } catch (error) {
      debugPrint('>>> IA-SDK: resetPrerequisites failed: $error');
      showMessage(context, 'Reset prerequisites failed: $error');
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
          FilledButton(onPressed: () => launchSdk(context), child: const Text('Launch IA SDK')),
          OutlinedButton(
            onPressed: () => resetPrerequisites(context),
            child: const Text('Reset Initialization and prerequisites'),
          ),
        ],
      ),
    );
  }
}
