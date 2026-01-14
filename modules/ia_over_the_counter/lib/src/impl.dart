import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'views.dart';

/// Method and property definitions for the ia.de AppSDK Over-the-Counter service.
///
class IaModuleOverTheCounter extends IaBaseOverTheCounter {
  @override
  Future<void> launchProductSearchRoute() async {
    return await _Views.productSearchScreen.launch();
  }
}
