import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'views.dart';

/// Method and property definitions for the ia.de AppSDK Over-the-Counter service.
///
class IaModuleOverTheCounter extends IaBaseOverTheCounter {
  @override
  Future<void> launchProductSearchRoute({
    bool? focusesOnAppear,
  }) async {
    return await _Views.searchScreen.launch(
      arguments: {
        'focusesOnAppear': focusesOnAppear,
      },
    );
  }

  @override
  Future<void> clearProductGridCache() async {
    return await _Methods.clearProductGridCache.invoke<void>(null);
  }
}
