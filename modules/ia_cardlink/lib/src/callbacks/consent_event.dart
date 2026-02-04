part of '../impl.dart';

Future<void> _consentEventHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'cardLinkConsentEvent: Invalid arguments type.',
    );
  }
  final eventType = args['event'];
  if (eventType is! String) {
    throw Exception(
      'cardLinkConsentEvent: Missing or incorrect type event: ${eventType.runtimeType} $eventType.',
    );
  }
  final consentEvent = IaCardLinkConsentEvent.fromRawValue(eventType);
  IaModuleCardLink._consentEventListener.add(consentEvent);
}
