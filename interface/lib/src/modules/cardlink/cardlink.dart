part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK CardLink service.
///
/// CardLink enables NFC-based prescription transfer functionality.
///
abstract class IaBaseCardLink extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.cardLink;
  }

  /// Launches the CardLink experience.
  ///
  /// Parameters:
  /// - [sdkApiKey]: The SDK API key for authentication (platform-specific).
  /// - [flowType]: The type of CardLink flow to launch (main flow or saved cards).
  /// - [pharmacyId]: The pharmacy identifier.
  /// - [consentStatus]: Initial consent status for the user.
  /// - [phoneNumber]: User's phone number.
  /// - [userId]: User identifier for card storage.
  /// - [canCode]: Optional pre-filled CAN code.
  /// - [cardName]: Optional name for the card being saved.
  /// - [primaryColor]: Optional primary UI color (as integer ARGB value).
  /// - [buttonsColor]: Optional buttons UI color (as integer ARGB value).
  /// - [textLinkColor]: Optional text link UI color (as integer ARGB value).
  /// - [bottomNavigationColor]: Optional bottom navigation UI color (as integer ARGB value).
  /// - [environment]: Optional SDK environment (defaults to production).
  /// - [saveCardEnabled]: Optional flag to enable card saving (defaults to true).
  /// - [finishAction]: Determines what happens with prescriptions after NFC scanning.
  /// - [appId]: Optional application ID (maps to `applicationId` on Android and `appID` on iOS).
  /// - [coreAppLogFileURL]: Optional file path to the host app's log file. When provided, the log file is included in CardLink's "Report Problem" feature, allowing users to attach app-level logs alongside CardLink logs when reporting issues.
  /// - [supportsLiquidGlass]: Flag to enable Liquid Glass UI style.
  /// - [illustrationColor]: Optional color of the CardLink illustrations (defaults to red). Only used on Android.
  /// - [mockInvalidXmlData]: QA option that makes the read prescriptions invalid, to test the error handling.
  ///   Only used on Android, see [setMocks] for iOS.
  ///
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
    required bool supportsLiquidGlass,
    IaCardLinkIllustrationColor? illustrationColor,
    bool? mockInvalidXmlData,
  });

  /// Returns the CardLink SDK version string.
  ///
  Future<String?> getVersion();

  /// Returns the current CardLink SDK environment.
  ///
  Future<IaCardLinkEnvironment> getEnvironment();

  /// Returns the path to the CardLink SDK log file.
  ///
  Future<String?> getLogFilePath();

  /// Returns the list of saved cards for the specified user.
  ///
  /// The returned string contains JSON-encoded card data.
  ///
  Future<String?> getSavedCards(String userId);

  /// Deletes a saved card for the specified user.
  ///
  /// Parameters:
  /// - [userId]: User identifier.
  /// - [cardName]: Name of the card to delete.
  ///
  Future<void> deleteCard({
    required String userId,
    required String cardName,
  });

  /// Replaces the details of a saved card.
  ///
  /// Parameters:
  /// - [userId]: User identifier.
  /// - [originalName]: Current name of the card to update.
  /// - [name]: New name of the card.
  /// - [phoneNumber]: Phone number linked to the card.
  /// - [canCode]: CAN code of the card.
  ///
  /// Note: Only supported on Android.
  ///
  Future<void> updateCard({
    required String userId,
    required String originalName,
    required String name,
    required String phoneNumber,
    required String canCode,
  });

  /// Changes the order in which saved cards are listed.
  ///
  /// Parameters:
  /// - [userId]: User identifier.
  /// - [orderedCanCodes]: CAN codes of the saved cards, in the new order.
  ///
  /// Note: Only supported on Android.
  ///
  Future<void> reorderSavedCards({
    required String userId,
    required List<String> orderedCanCodes,
  });

  /// Deletes all saved cards.
  ///
  /// Returns a status string indicating the result:
  /// - "successDeleteAll": All cards were deleted.
  /// - "emptyStorage": No cards to delete.
  ///
  /// Note: On Android all CardLink data is cleared and `null` is returned.
  ///
  Future<String?> deleteAllCards();

  /// Deletes all user-related data from the CardLink SDK.
  ///
  /// This includes saved cards and any other user-specific data.
  ///
  Future<void> deleteAllUserRelatedData();

  /// Sets the host app's log file, which users can attach to CardLink problem reports.
  ///
  /// [IaSdkConfiguration.hostAppLogFilePath] calls this automatically when the CardLink module is registered.
  ///
  Future<void> setHostAppLogFilePath(String path);

  /// Replaces the CardLink backend with simulated responses, for testing CardLink flows. Not meant for production builds.
  ///
  /// Note: Only supported on iOS. On Android see the `mockInvalidXmlData` option of [launch].
  ///
  Future<void> setMocks(IaCardLinkMocks mocks);

  /// Programmatically finishes the active CardLink session.
  ///
  /// Note: Only has an effect on iOS.
  ///
  Future<void> finish();

  /// Notifier for consent events (accepted or declined).
  ///
  /// Consolidates consent accepted/declined into a single stream with status differentiation.
  ///
  /// Usage:
  ///
  /// ```dart
  /// consentEventListener.stream.listen((event) {
  ///   if (event == IaCardLinkConsentEvent.accepted) {
  ///     // Handle consent accepted
  ///   } else {
  ///     // Handle consent declined
  ///   }
  /// });
  /// ```
  ///
  StreamController<IaCardLinkConsentEvent> get consentEventListener;

  /// Notifier for CardLink session creation.
  ///
  /// Emits session data when a CardLink session is successfully created.
  ///
  /// Usage:
  ///
  /// ```dart
  /// sessionCreatedListener.stream.listen((session) {
  ///   // Process session data
  /// });
  /// ```
  ///
  StreamController<IaCardLinkSession> get sessionCreatedListener;

  /// Notifier for prescriptions redeemed events.
  ///
  /// Emits prescription data when prescriptions are successfully redeemed.
  ///
  /// Usage:
  ///
  /// ```dart
  /// prescriptionsRedeemedListener.stream.listen((prescriptions) {
  ///   // Process redeemed prescriptions
  /// });
  /// ```
  ///
  StreamController<String> get prescriptionsRedeemedListener;

  /// Notifier for CardLink lifecycle and interaction events.
  ///
  /// Consolidates various events into a single stream:
  /// - [IaCardLinkEvent.willExit]: CardLink will close
  /// - [IaCardLinkEvent.willStartScanning]: NFC scanning is about to start
  /// - [IaCardLinkEvent.failedToInitialize]: Initialization failed
  /// - [IaCardLinkEvent.goToCart]: User requested to go to cart
  /// - [IaCardLinkEvent.openTermsAndConditions]: User requested to view terms
  /// - [IaCardLinkEvent.cardSaved]: A card was saved
  ///
  /// Usage:
  ///
  /// ```dart
  /// eventListener.stream.listen((event) {
  ///   switch (event) {
  ///     case IaCardLinkEvent.willExit:
  ///       // Handle exit
  ///       break;
  ///     case IaCardLinkEvent.goToCart:
  ///       // Navigate to cart
  ///       break;
  ///     // ... handle other events
  ///   }
  /// });
  /// ```
  ///
  StreamController<IaCardLinkEvent> get eventListener;

  /// Notifier for analytics events.
  ///
  /// Emits analytics event strings for tracking purposes.
  ///
  /// Usage:
  ///
  /// ```dart
  /// analyticsEventListener.stream.listen((eventName) {
  ///   // Log analytics event
  /// });
  /// ```
  ///
  StreamController<String> get analyticsEventListener;

  /// Notifier for the phone number the user entered when accepting the consent.
  ///
  /// Note: Only reported on iOS, the Android SDK asks the host for the phone number instead.
  ///
  StreamController<String> get consentPhoneNumberListener;

  /// Notifier for the cards saved with [IaCardLinkEvent.cardSaved].
  ///
  StreamController<List<IaCardLinkSavedCard>> get savedCardsListener;

  /// Notifier for the error description of [IaCardLinkEvent.failedToInitialize], `null` if none is reported.
  ///
  /// Note: The description is only reported on iOS.
  ///
  StreamController<String?> get initializationErrorListener;

  /// Notifier for the result of [IaCardLinkEvent.finished]: the result message, or `"canceled"` when the user
  /// cancelled CardLink.
  ///
  /// Note: Only reported on Android.
  ///
  StreamController<String?> get resultListener;
}
