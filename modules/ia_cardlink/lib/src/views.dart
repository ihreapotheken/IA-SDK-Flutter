part of 'impl.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  cardLinkScreen,
  savedCardsScreen,
  ;

  @override
  String get viewId {
    return name;
  }

  @override
  Future<void> launch() async {
    return await _Methods._channel.invokeMethod(
      IaBaseViews.launchMethodId,
      {
        IaBaseViews.launchMethodArgId: Platform.isAndroid ? viewId.substring(0, 1).toUpperCase() + viewId.substring(1) : viewId,
      },
    );
  }
}
