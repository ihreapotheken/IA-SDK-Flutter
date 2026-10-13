part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK CardLink service.
///
/// CardLink enables NFC-based prescription transfer functionality.
///
/// Methods documented as "Only supported on iOS" or "Only supported on Android" throw a
/// [MissingPluginException] on the other platform. Callbacks and streams with such a note never fire there.
///
/// Failed calls throw a [PlatformException]. Its code is `INVALID_ARGUMENTS` or `MISSING_<ARGUMENT>` for invalid
/// arguments, and otherwise names the method, for example `GET_SAVED_CARDS_ERROR` or `DELETE_CARD_ERROR`.
/// [launch] fails with `NO_ACTIVITY` on Android and `NO_VIEW_CONTROLLER` on iOS when there's no screen to show
/// CardLink on.
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
  ///   On iOS CardLink uses the SDK-wide color palette. Passing any of these colors replaces it until CardLink
  ///   closes, with SDK defaults for the palette colors not passed. Without colors the palette stays unchanged.
  /// - [environment]: Optional CardLink environment. When `null`, the environment `IaSdk` was initialized with
  ///   is used. On iOS, passing it also switches the environment of the whole SDK.
  /// - [saveCardEnabled]: Optional flag to enable card saving (defaults to true).
  /// - [finishAction]: Determines what happens with prescriptions after NFC scanning. Only used on iOS, where
  ///   [IaCardLinkFinishAction.uploadPrescriptions] needs the Ordering module and an initialized SDK. On Android
  ///   the prescriptions are always only reported through [prescriptionsRedeemedListener], as with
  ///   [IaCardLinkFinishAction.sendRawPrescriptions]; they aren't added to the cart.
  /// - [appId]: Optional application ID (maps to `applicationId` on Android and to the SDK-wide
  ///   `IASDK.configuration.appStoreID` on iOS).
  /// - [coreAppLogFileURL]: Optional file path (not a URL) to the host app's log file, which users can attach to
  ///   problem reports. It replaces the host log file set with `IaSdkConfiguration.hostAppLogFilePath` or
  ///   [setHostAppLogFilePath], on iOS for the problem reports of all SDK screens, and stays set after CardLink
  ///   closes.
  /// - [supportsLiquidGlass]: Optional flag to enable Liquid Glass UI style. Only used on iOS, where it also changes
  ///   the setting for all SDK screens. When `null`, the setting from `IaSdk.initialize` is kept.
  /// - [illustrationColor]: Optional color of the CardLink illustrations (defaults to red). Only used on Android.
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
    bool? supportsLiquidGlass,
    IaCardLinkIllustrationColor? illustrationColor,
  });

  /// Returns the CardLink SDK version string.
  ///
  Future<String?> getVersion();

  /// Returns the current CardLink SDK environment.
  ///
  /// Before the first [launch], this is the environment `IaSdk` was initialized with.
  ///
  Future<IaCardLinkEnvironment> getEnvironment();

  /// Returns the path to the CardLink SDK log file, or `null` when it isn't available.
  ///
  /// On iOS this is an exported copy of the logs, limited in size.
  ///
  Future<String?> getLogFilePath();

  /// Returns the list of saved cards for the specified user.
  ///
  /// The returned string contains JSON-encoded card data. Fails when the stored cards can't be read.
  ///
  Future<String?> getSavedCards(String userId);

  /// Returns the saved cards for the specified user, parsed from [getSavedCards].
  ///
  Future<List<IaCardLinkSavedCard>> getSavedCardList(String userId);

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
  /// `IaSdk.initialize` and `IaSdk.register` call this with `IaSdkConfiguration.hostAppLogFilePath`, whichever
  /// of them runs second, so a file set here before then is replaced. [launch] with `coreAppLogFileURL` replaces
  /// it too.
  ///
  /// On Android an empty [path] keeps the previously set file, the SDK can't detach it.
  ///
  Future<void> setHostAppLogFilePath(String path);

  /// Replaces the CardLink backend with simulated responses, for testing CardLink flows. Not meant for production builds.
  ///
  /// Note: Only supported on iOS. The Android SDK's only CardLink mock is disabled in its release builds.
  ///
  Future<void> setMocks(IaCardLinkMocks mocks);

  /// Programmatically finishes the active CardLink session.
  ///
  /// Completes right away when no CardLink screen is shown. Right after [launch], CardLink signs in before it shows
  /// anything; `finish` has no effect then, and CardLink opens afterwards.
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
  /// On iOS, with [IaCardLinkFinishAction.uploadPrescriptions] the SDK adds the prescriptions to the cart itself.
  /// They're reported here too, in the same JSON format but without each prescription's `token`.
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
  /// - [IaCardLinkEvent.willExit]: CardLink has closed. It's reported once CardLink is gone.
  /// - [IaCardLinkEvent.willStartScanning]: NFC scanning is about to start. Only reported on iOS.
  /// - [IaCardLinkEvent.failedToInitialize]: Initialization failed
  /// - [IaCardLinkEvent.goToCart]: User requested to go to cart. Only reported on Android.
  /// - [IaCardLinkEvent.openTermsAndConditions]: User requested to view terms
  /// - [IaCardLinkEvent.cardSaved]: A card was saved
  /// - [IaCardLinkEvent.finished]: CardLink closed with a result (Android), see [resultListener]
  ///
  /// On iOS, CardLink flows the SDK starts itself (for example from the "redeem prescription" screen) report
  /// consent, session, prescription (see [prescriptionsRedeemedListener]), saved-card, error and analytics events
  /// too. Their [IaCardLinkEvent.willExit] isn't reported, because the SDK closes and reopens them itself. Their
  /// [IaCardLinkEvent.openTermsAndConditions] is, as the SDK only closes CardLink for it.
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
  /// On iOS each event carries all saved cards of the user, on Android only the card just saved.
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
