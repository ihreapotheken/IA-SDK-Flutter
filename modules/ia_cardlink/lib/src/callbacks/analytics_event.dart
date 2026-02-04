part of '../impl.dart';

Future<void> _analyticsEventHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'cardLinkAnalyticsEvent: Invalid arguments type.',
    );
  }
  final eventName = args['analyticEvent'];
  if (eventName is! String) {
    throw Exception(
      'cardLinkAnalyticsEvent: Missing or incorrect type analyticEvent: ${eventName.runtimeType} $eventName.',
    );
  }
  IaModuleCardLink._analyticsEventListener.add(eventName);
}
