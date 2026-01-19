part of '../impl.dart';

enum _Callbacks implements IaBaseCallbackHandler {
  orderingDidFinishOrder,
  orderingDidUpdateCart,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return switch (this) {
      _Callbacks.orderingDidFinishOrder => _orderingDidFinishOrderHandler,
      _Callbacks.orderingDidUpdateCart => _orderingDidUpdateCartHandler,
    };
  }
}
