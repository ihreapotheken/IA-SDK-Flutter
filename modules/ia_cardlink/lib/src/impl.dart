import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'views.dart';
part 'models/request/launch.dart';
part 'models/request/get_saved_cards.dart';
part 'models/request/delete_card.dart';
part 'callbacks/_callbacks.dart';
part 'callbacks/consent_event.dart';
part 'callbacks/session_created.dart';
part 'callbacks/prescriptions_redeemed.dart';
part 'callbacks/event.dart';
part 'callbacks/analytics_event.dart';

/// Method and property definitions for the ia.de AppSDK CardLink service.
///
class IaModuleCardLink extends IaBaseCardLink {
  @override
  Future<void> launch({
    required String sdkApiKey,
    required IaCardLinkFlowType flowType,
    required String pharmacyId,
    required IaCardLinkConsentStatus consentStatus,
    required String phoneNumber,
    required String userId,
    String? canCode,
    String? cardName,
    int? primaryColor,
    int? buttonsColor,
    int? textLinkColor,
    int? bottomNavigationColor,
    IaCardLinkEnvironment? environment,
    bool? saveCardEnabled,
  }) async {
    final arguments = _RequestModelLaunch(
      sdkApiKey: sdkApiKey,
      flowType: flowType,
      pharmacyId: pharmacyId,
      consentStatus: consentStatus,
      phoneNumber: phoneNumber,
      userId: userId,
      canCode: canCode,
      cardName: cardName,
      primaryColor: primaryColor,
      buttonsColor: buttonsColor,
      textLinkColor: textLinkColor,
      bottomNavigationColor: bottomNavigationColor,
      environment: environment,
      saveCardEnabled: saveCardEnabled,
    );
    return await _Methods.launch.invoke<void>(arguments);
  }

  @override
  Future<String?> getVersion() async {
    return await _Methods.getVersion.invoke<String?>(null);
  }

  @override
  Future<IaCardLinkEnvironment> getEnvironment() async {
    final rawValue = await _Methods.getEnvironment.invoke<String?>(null);
    return IaCardLinkEnvironment.fromRawValue(rawValue);
  }

  @override
  Future<String?> getLogFilePath() async {
    return await _Methods.getLogFilePath.invoke<String?>(null);
  }

  @override
  Future<String?> getSavedCards(String userId) async {
    final arguments = _RequestModelGetSavedCards(userId: userId);
    return await _Methods.getSavedCards.invoke<String?>(arguments);
  }

  @override
  Future<void> deleteCard({
    required String userId,
    required String cardName,
  }) async {
    final arguments = _RequestModelDeleteCard(
      userId: userId,
      cardName: cardName,
    );
    return await _Methods.deleteCard.invoke<void>(arguments);
  }

  @override
  Future<String?> deleteAllCards() async {
    return await _Methods.deleteAllCards.invoke<String?>(null);
  }

  @override
  Future<void> deleteAllUserRelatedData() async {
    return await _Methods.deleteAllUserRelatedData.invoke<void>(null);
  }

  static final _consentEventListener = StreamController<IaCardLinkConsentEvent>.broadcast();

  @override
  StreamController<IaCardLinkConsentEvent> get consentEventListener {
    return _consentEventListener;
  }

  static final _sessionCreatedListener = StreamController<IaCardLinkSession>.broadcast();

  @override
  StreamController<IaCardLinkSession> get sessionCreatedListener {
    return _sessionCreatedListener;
  }

  static final _prescriptionsRedeemedListener = StreamController<String>.broadcast();

  @override
  StreamController<String> get prescriptionsRedeemedListener {
    return _prescriptionsRedeemedListener;
  }

  static final _eventListener = StreamController<IaCardLinkEvent>.broadcast();

  @override
  StreamController<IaCardLinkEvent> get eventListener {
    return _eventListener;
  }

  static final _analyticsEventListener = StreamController<String>.broadcast();

  @override
  StreamController<String> get analyticsEventListener {
    return _analyticsEventListener;
  }

  @override
  final callbacks = IaBaseCallbacks(
    channel: _Methods._channel,
    handlers: _Callbacks.values,
  );
}
