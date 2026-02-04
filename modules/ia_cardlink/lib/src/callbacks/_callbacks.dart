part of '../impl.dart';

enum _Callbacks implements IaBaseCallbackHandler {
  cardLinkConsentEvent,
  cardLinkSessionCreated,
  cardLinkPrescriptionsRedeemed,
  cardLinkEvent,
  cardLinkAnalyticsEvent,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return switch (this) {
      _Callbacks.cardLinkConsentEvent => _consentEventHandler,
      _Callbacks.cardLinkSessionCreated => _sessionCreatedHandler,
      _Callbacks.cardLinkPrescriptionsRedeemed => _prescriptionsRedeemedHandler,
      _Callbacks.cardLinkEvent => _eventHandler,
      _Callbacks.cardLinkAnalyticsEvent => _analyticsEventHandler,
    };
  }
}
