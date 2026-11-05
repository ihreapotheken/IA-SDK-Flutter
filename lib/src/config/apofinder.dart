part of '../core.dart';

/// Configuration options for Apofinder.
///
class IaSdkConfigurationApofinder {
  /// Generates an instance of Apofinder configuration.
  ///
  const IaSdkConfigurationApofinder({
    this.deliveryQuickFilter = IaSdkApofinderDeliveryQuickFilter.delivery,
    this.isDeliveryQuickFilterPreselected = false,
  });

  /// Delivery option shown as a quick filter in Apofinder. The other one stays available in the filter list.
  ///
  /// [IaSdkApofinderDeliveryQuickFilter.courierShipping] needs
  /// [IaSdkConfiguration.isPickupLockerAndCourierShippingEnabled]. Without it Apofinder doesn't offer "Versand" at
  /// all and shows [IaSdkApofinderDeliveryQuickFilter.delivery] instead.
  ///
  final IaSdkApofinderDeliveryQuickFilter deliveryQuickFilter;

  /// Whether the delivery quick filter is already selected when the user opens Apofinder.
  ///
  /// When "Versand" isn't offered, this preselects "Botendienst".
  ///
  final bool isDeliveryQuickFilterPreselected;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'deliveryQuickFilter': deliveryQuickFilter.name,
      'isDeliveryQuickFilterPreselected': isDeliveryQuickFilterPreselected,
    };
  }
}

/// Delivery option shown as a quick filter in Apofinder, see [IaSdkConfigurationApofinder.deliveryQuickFilter].
///
enum IaSdkApofinderDeliveryQuickFilter {
  /// "Botendienst", the pharmacy's own delivery service.
  ///
  delivery,

  /// "Versand", shipping.
  ///
  courierShipping,
}
