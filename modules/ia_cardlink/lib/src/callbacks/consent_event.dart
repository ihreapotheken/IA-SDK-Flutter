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
  final phoneNumber = args['phoneNumber'];
  if (phoneNumber is String && phoneNumber.isNotEmpty) {
    IaModuleCardLink._consentPhoneNumberListener.add(phoneNumber);
  }
  IaModuleCardLink._consentEventListener.add(consentEvent);
}
