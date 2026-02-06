part of '../impl.dart';

Future<void> _consentEventHandler(dynamic args) async {
  if (args is! Map) {
    throw Exception(
      'cardLinkConsentEvent: Invalid arguments type.',
    );
  }
  final eventType = args['status'];
  if (eventType is! String) {
    throw Exception(
      'cardLinkConsentEvent: Missing or incorrect type status: ${eventType.runtimeType} $eventType.',
    );
  }
  final consentEvent = IaCardLinkConsentEvent.fromRawValue(eventType);
  IaModuleCardLink._consentEventListener.add(consentEvent);
}
