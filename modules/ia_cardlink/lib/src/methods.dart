part of 'impl.dart';

enum _Methods with IaBaseMethods implements IaBaseMethods {
  launch,
  getVersion,
  getEnvironment,
  getLogFilePath,
  getSavedCards,
  deleteCard,
  deleteAllCards,
  deleteAllUserRelatedData,
  ;

  /// Custom channel identifier for the CardLink plugin.
  ///
  static const _channelId = 'de.ihreapotheken/sdk/cardLink';

  /// Custom [MethodChannel] object implementation specified for the CardLink plugin.
  ///
  static const _channel = MethodChannel(_channelId);

  @override
  MethodChannel get channel {
    return _channel;
  }

  @override
  String get methodId {
    return name;
  }

  @override
  Type? get argumentType {
    switch (this) {
      case _Methods.launch:
        return _RequestModelLaunch;
      case _Methods.getSavedCards:
        return _RequestModelGetSavedCards;
      case _Methods.deleteCard:
        return _RequestModelDeleteCard;
      default:
        return null;
    }
  }
}
