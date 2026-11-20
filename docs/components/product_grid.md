# Product Grid

* `IaProductGrid` is a UI component that embeds a grid of pharmacy products directly into your layout.
* Supports multiple product types: current offers, products of the month, product recommendations, customers also
  bought, and custom PZN lists.
* Tapping a product opens product details. If `ia_ordering` is registered, users can add products to the cart.
* You can use the `shouldShowLoading` parameter to control whether you want to hide the grid while loading or show a
  loading indicator.

> [!IMPORTANT]
> SDK initialization and prerequisites (pharmacy selection) must be completed before using this component. To learn
> more, see [How to use components](how_to_use_components.md).

> [!NOTE]
> For a video of the component, see [IAProductGrid](https://github.com/ihreapotheken/IA-SDK-iOS/blob/main/Docs/Components/IAProductGrid.md)
> in the iOS SDK docs. It shows the iOS version.

## Overview
- Package: `ia_over_the_counter`
- Dependencies:
  - `ia_ordering` (Optional):
    - Add product to the cart.

## Example

`IaProductGrid` with current offers.

```dart
const IaProductGrid(type: IaProductDisplayType.currentOffers)
```

`IaProductGrid` with recommendations for a specific product.

```dart
const IaProductGrid(
  type: IaProductDisplayType.productRecommendations,
  pzn: '12345678',
)
```

`IaProductGrid` with your own selection of products.

```dart
const IaProductGrid(
  type: IaProductDisplayType.custom,
  title: 'Our picks',
  pzns: ['12345678', '87654321'],
)
```

**Parameters**
  - **type**: Product collection to display.
  - **pzn**: Product identifier the recommendation-based types (`productRecommendations`, `customersAlsoBought`) are
    based on. Without one they show no products.
  - **shouldShowLoading**: Whether to show a loading indicator while products load. Defaults to `true`.
  - **title**: Title of the grid, for the `custom` type.
  - **pzns**: Product identifiers to show, for the `custom` type. Required for the `custom` type.

> [!NOTE]
> The native grid reads its parameters once, when it's created, so changing any of them recreates it and loads the
> products again.

## Platform differences
- **pzn:** For `currentOffers` and `productsOfTheMonth`, iOS leaves this product out of the grid. Android ignores it
  for those types.
- **Activity:** On Android the app's activity must be a `ComponentActivity`, such as `FlutterFragmentActivity`.
