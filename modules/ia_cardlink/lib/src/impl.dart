import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'models/request/launch.dart';
part 'models/request/get_saved_cards.dart';
part 'models/request/delete_card.dart';
part 'models/request/update_card.dart';
part 'models/request/reorder_saved_cards.dart';
part 'models/request/set_mocks.dart';
part 'models/request/set_host_app_log_file_path.dart';
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
    required IaCardLinkFinishAction finishAction,
    String? canCode,
    String? cardName,
    int? primaryColor,
    int? buttonsColor,
    int? textLinkColor,
    int? bottomNavigationColor,
    IaCardLinkEnvironment? environment,
    bool? saveCardEnabled,
    String? appId,
    String? coreAppLogFileURL,
    bool? supportsLiquidGlass,
    IaCardLinkIllustrationColor? illustrationColor,
  }) async {
    final arguments = _RequestModelLaunch(
      sdkApiKey: sdkApiKey,
      flowType: flowType,
      pharmacyId: pharmacyId,
      consentStatus: consentStatus,
      phoneNumber: phoneNumber,
      userId: userId,
      finishAction: finishAction,
      canCode: canCode,
      cardName: cardName,
      primaryColor: primaryColor,
      buttonsColor: buttonsColor,
      textLinkColor: textLinkColor,
      bottomNavigationColor: bottomNavigationColor,
      environment: environment,
      saveCardEnabled: saveCardEnabled,
      appId: appId,
      coreAppLogFileURL: coreAppLogFileURL,
      supportsLiquidGlass: supportsLiquidGlass,
      illustrationColor: illustrationColor,
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
  Future<List<IaCardLinkSavedCard>> getSavedCardList(String userId) async {
    final json = await getSavedCards(userId);
    if (json == null || json.isEmpty) return const [];
    final cards = jsonDecode(json);
    if (cards is! List) return const [];
    return cards.whereType<Map>().map((card) {
      final savedCard = IaCardLinkSavedCard.fromMap(Map<String, dynamic>.from(card));
      // Android's card JSON uses "id" for the user identifier, not a card identifier.
      return Platform.isAndroid
          ? IaCardLinkSavedCard(name: savedCard.name, canCode: savedCard.canCode, phoneNumber: savedCard.phoneNumber)
          : savedCard;
    }).toList();
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
  Future<void> updateCard({
    required String userId,
    required String originalName,
    required String name,
    required String phoneNumber,
    required String canCode,
  }) async {
    final arguments = _RequestModelUpdateCard(
      userId: userId,
      originalName: originalName,
      name: name,
      phoneNumber: phoneNumber,
      canCode: canCode,
    );
    return await _Methods.updateCard.invoke<void>(arguments);
  }

  @override
  Future<void> reorderSavedCards({
    required String userId,
    required List<String> orderedCanCodes,
  }) async {
    final arguments = _RequestModelReorderSavedCards(
      userId: userId,
      orderedCanCodes: orderedCanCodes,
    );
    return await _Methods.reorderSavedCards.invoke<void>(arguments);
  }

  @override
  Future<String?> deleteAllCards() async {
    return await _Methods.deleteAllCards.invoke<String?>(null);
  }

  @override
  Future<void> deleteAllUserRelatedData() async {
    return await _Methods.deleteAllUserRelatedData.invoke<void>(null);
  }

  @override
  Future<void> setHostAppLogFilePath(String path) async {
    final arguments = _RequestModelSetHostAppLogFilePath(
      path: path,
    );
    return await _Methods.setHostAppLogFilePath.invoke<void>(arguments);
  }

  @override
  Future<void> setMocks(IaCardLinkMocks mocks) async {
    final arguments = _RequestModelSetMocks(
      mocks: mocks,
    );
    return await _Methods.setMocks.invoke<void>(arguments);
  }

  @override
  Future<void> finish() async {
    return await _Methods.finish.invoke<void>(null);
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

  static final _consentPhoneNumberListener = StreamController<String>.broadcast();

  @override
  StreamController<String> get consentPhoneNumberListener {
    return _consentPhoneNumberListener;
  }

  static final _savedCardsListener = StreamController<List<IaCardLinkSavedCard>>.broadcast();

  @override
  StreamController<List<IaCardLinkSavedCard>> get savedCardsListener {
    return _savedCardsListener;
  }

  static final _initializationErrorListener = StreamController<String?>.broadcast();

  @override
  StreamController<String?> get initializationErrorListener {
    return _initializationErrorListener;
  }

  static final _resultListener = StreamController<String?>.broadcast();

  @override
  StreamController<String?> get resultListener {
    return _resultListener;
  }

  @override
  IaBaseCallbacks get callbacks {
    return _callbacks;
  }

  // Shared by all instances, like the streams, so creating more instances doesn't add more subscribers.
  static final _callbacks = IaBaseCallbacks(
    channel: _Methods._channel,
    handlers: _Callbacks.values,
  );
}
