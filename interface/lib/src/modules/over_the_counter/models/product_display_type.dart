part of '_models.dart';

/// Product display type determining which product collection to show.
///
enum IaProductDisplayType {
  /// Currently active pharmacy offers.
  ///
  currentOffers,

  /// Monthly featured products.
  ///
  productsOfTheMonth,

  /// Product recommendations based on a specific product (pzn).
  ///
  productRecommendations,

  /// Products that other customers also bought based on a specific product (pzn).
  ///
  customersAlsoBought;
}
