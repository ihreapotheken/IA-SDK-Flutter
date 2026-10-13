part of '_models.dart';

/// What the SDK shows after prescriptions were transferred with `transferPrescriptions`.
///
enum IaTransferPrescriptionsFinishAction {
  /// Opens the cart.
  ///
  openCart,

  /// Shows a confirmation bottom sheet.
  ///
  showBottomSheet,

  /// Shows nothing.
  ///
  /// Note: Only supported on iOS. Android opens the cart instead.
  ///
  noAction,
}
