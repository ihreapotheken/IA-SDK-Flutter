import 'package:appsdk_v2_flutter_plugin/common/entities/ordering/ia_cart_state.dart';
import 'package:appsdk_v2_flutter_plugin/common/entities/ia_handling_decision.dart';
import 'package:appsdk_v2_flutter_plugin/common/entities/ordering/ia_order.dart';
import 'package:appsdk_v2_flutter_plugin/common/entities/ia_route_override.dart';

/// Callbacks that allow the host app to observe and respond to SDK events.
///
/// Set these callbacks to receive events from the SDK, such as navigation requests
/// or state changes.
///
class IaSdkCallbacks {
  /// Called when the SDK is about to navigate to a destination that your app can override.
  ///
  /// For example, if the SDK would present the Cart by default, your app can switch to its
  /// own Cart tab and return [IaHandlingDecision.handled]. Return [IaHandlingDecision.performDefault]
  /// to let the SDK proceed with its built-in presentation.
  ///
  /// Example:
  /// ```dart
  /// final iaSdk = IaSdk.of(context);
  /// iaSdk?.callbacks.onShouldOverrideRoute = (routeOverride) async {
  ///   if (routeOverride == IaRouteOverride.cart) {
  ///     // Switch to your own cart tab
  ///     switchToTab(TabType.cart);
  ///     return IaHandlingDecision.handled;
  ///   }
  ///   return IaHandlingDecision.performDefault;
  /// };
  /// ```
  Future<IaHandlingDecision> Function(IaRouteOverride routeOverride)? onShouldOverrideRoute;

  /// Called when the user completes an order.
  ///
  /// This is a fire-and-forget callback that notifies the host app when an order
  /// has been successfully placed.
  ///
  /// Example:
  /// ```dart
  /// final iaSdk = IaSdk.of(context);
  /// iaSdk?.callbacks.onDidFinishOrder = (order) {
  ///   print('Order completed: ${order}');
  /// };
  /// ```
  void Function(IaOrder order)? onDidFinishOrder;

  /// Called when the shopping cart state changes.
  ///
  /// This callback is triggered whenever items are added to or removed from the cart,
  /// or when quantities change.
  ///
  /// Example:
  /// ```dart
  /// final iaSdk = IaSdk.of(context);
  /// iaSdk?.callbacks.onDidUpdateCart = (cartState) {
  ///   print('Cart updated: ${cartState.cartDetails?.totalAmountInCart ?? 0} items');
  /// };
  /// ```
  void Function(IaCartState cartState)? onDidUpdateCart;
}
