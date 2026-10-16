import 'dart:async';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_example_demo/src/testing/event_log.dart';
import 'package:flutter/foundation.dart';

/// How the example answers the prescription scan callbacks.
///
enum ExampleScanDecision {
  performDefault,
  handled,
  error;

  IaModelPrescriptionScanDecision get sdkDecision {
    return switch (this) {
      ExampleScanDecision.performDefault => IaModelPrescriptionScanDecision.performDefault,
      ExampleScanDecision.handled => IaModelPrescriptionScanDecision.handled,
      ExampleScanDecision.error => const IaModelPrescriptionScanDecision.error('Rejected by the example app.'),
    };
  }
}

/// How the example app answers the SDK callbacks, switchable in the Events tab to test each behavior.
///
class ExampleTestSettings extends ChangeNotifier {
  ExampleTestSettings._();

  static final instance = ExampleTestSettings._();

  bool _handlesNavigation = false;

  /// Whether `onSdkWillNavigateToTarget` reports every target as handled by the host, so the SDK doesn't navigate.
  ///
  bool get handlesNavigation => _handlesNavigation;

  set handlesNavigation(bool value) {
    _handlesNavigation = value;
    notifyListeners();
  }

  bool _blocksBackAction = false;

  /// Whether `onSdkBackAction` keeps SDK screens open (Android).
  ///
  bool get blocksBackAction => _blocksBackAction;

  set blocksBackAction(bool value) {
    _blocksBackAction = value;
    notifyListeners();
  }

  ExampleScanDecision _scanDecision = ExampleScanDecision.performDefault;

  /// The answer to the prescription scan callbacks.
  ///
  ExampleScanDecision get scanDecision => _scanDecision;

  set scanDecision(ExampleScanDecision value) {
    _scanDecision = value;
    notifyListeners();
  }

  StreamSubscription<IaSdkLogMessage>? _logMessageSubscription;

  /// Whether the SDK's log messages are added to the event log (iOS). The SDK logs a lot, so it's off by default.
  ///
  bool get logsSdkMessages => _logMessageSubscription != null;

  set logsSdkMessages(bool value) {
    if (value == logsSdkMessages) return;
    if (value) {
      _logMessageSubscription = IaSdk.instance.logMessageListener.stream.listen((message) {
        ExampleEventLog.instance.add('SDK log', '${message.level}: ${message.message}');
      });
    } else {
      _logMessageSubscription?.cancel();
      _logMessageSubscription = null;
    }
    notifyListeners();
  }
}
