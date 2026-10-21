part of '_models.dart';

/// Color of the illustrations in CardLink screens.
///
enum IaCardLinkIllustrationColor {
  /// Red illustrations, the SDK default.
  ///
  red,

  /// Blue illustrations.
  ///
  blue,

  /// Pink illustrations.
  ///
  pink,

  /// Green illustrations.
  ///
  green,

  /// Orange illustrations.
  ///
  orange,

  /// Yellow illustrations.
  ///
  yellow,

  /// Purple illustrations.
  ///
  purple;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    return name.toUpperCase();
  }
}
