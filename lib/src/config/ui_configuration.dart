part of '../core.dart';

/// Header style options for SDK navigation bars and headers.
///
enum IaHeaderStyle {
  /// Uses primary color as background and secondary color for illustration.
  duotone,

  /// Uses only primary color as background.
  monotone,
}

/// Configuration options for SDK header appearance.
///
class IaHeaderConfiguration {
  /// Generates an instance of header configuration.
  ///
  const IaHeaderConfiguration({
    this.style = IaHeaderStyle.duotone,
    this.primaryColor,
    this.secondaryColor,
  });

  /// The header rendering style.
  ///
  final IaHeaderStyle style;

  /// The background color of navigation bars and headers.
  ///
  /// Defaults to Brand Color (Markenfarbe) set on BEP.
  ///
  final Color? primaryColor;

  /// The illustration color in navigation bars and headers.
  ///
  /// Only used when [style] is [IaHeaderStyle.duotone].
  /// Defaults to a lighter shade of Brand Color set on BEP.
  ///
  final Color? secondaryColor;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'style': style.name,
      'primaryColor': primaryColor?.toARGB32(),
      'secondaryColor': secondaryColor?.toARGB32(),
    };
  }
}

/// Configuration options for SDK primary button appearance.
///
class IaPrimaryButtonConfiguration {
  /// Generates an instance of primary button configuration.
  ///
  const IaPrimaryButtonConfiguration({
    this.backgroundColor,
    this.backgroundDisabledColor,
    this.textColor,
    this.textDisabledColor,
    this.borderColor,
    this.borderDisabledColor,
    this.borderWidth,
    this.borderRadius,
  });

  /// Background color of the button.
  final Color? backgroundColor;

  /// Background color of the button when disabled.
  final Color? backgroundDisabledColor;

  /// Text color of the button.
  final Color? textColor;

  /// Text color of the button when disabled.
  final Color? textDisabledColor;

  /// Border color of the button. Requires [borderWidth] >= 1 to render.
  final Color? borderColor;

  /// Border color of the button when disabled. Requires [borderWidth] >= 1 to render.
  final Color? borderDisabledColor;

  /// Border width in logical pixels. Values less than 1 are ignored.
  final double? borderWidth;

  /// Border radius in logical pixels. Values less than 0 are ignored.
  final double? borderRadius;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor?.toARGB32(),
      'backgroundDisabledColor': backgroundDisabledColor?.toARGB32(),
      'textColor': textColor?.toARGB32(),
      'textDisabledColor': textDisabledColor?.toARGB32(),
      'borderColor': borderColor?.toARGB32(),
      'borderDisabledColor': borderDisabledColor?.toARGB32(),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
    };
  }
}

/// Configuration options for SDK secondary button appearance.
///
class IaSecondaryButtonConfiguration {
  /// Generates an instance of secondary button configuration.
  ///
  const IaSecondaryButtonConfiguration({
    this.backgroundColor,
    this.backgroundDisabledColor,
    this.textColor,
    this.textDisabledColor,
    this.borderColor,
    this.borderDisabledColor,
    this.borderWidth,
    this.borderRadius,
  });

  /// Background color of the button.
  final Color? backgroundColor;

  /// Background color of the button when disabled.
  final Color? backgroundDisabledColor;

  /// Text color of the button.
  final Color? textColor;

  /// Text color of the button when disabled.
  final Color? textDisabledColor;

  /// Border color of the button. Requires [borderWidth] >= 1 to render.
  final Color? borderColor;

  /// Border color of the button when disabled. Requires [borderWidth] >= 1 to render.
  final Color? borderDisabledColor;

  /// Border width in logical pixels. Values less than 1 are ignored.
  final double? borderWidth;

  /// Border radius in logical pixels. Values less than 0 are ignored.
  final double? borderRadius;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor?.toARGB32(),
      'backgroundDisabledColor': backgroundDisabledColor?.toARGB32(),
      'textColor': textColor?.toARGB32(),
      'textDisabledColor': textDisabledColor?.toARGB32(),
      'borderColor': borderColor?.toARGB32(),
      'borderDisabledColor': borderDisabledColor?.toARGB32(),
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
    };
  }
}

/// Configuration options for SDK UI appearance.
///
class IaUIConfiguration {
  /// Generates an instance of UI configuration.
  ///
  const IaUIConfiguration({
    this.supportsLiquidGlass = false,
    this.header = const IaHeaderConfiguration(),
    this.primaryButton = const IaPrimaryButtonConfiguration(),
    this.secondaryButton = const IaSecondaryButtonConfiguration(),
  });

  /// Whether the host app supports Liquid Glass.
  ///
  /// Only supported on iOS. Ignored on Android.
  ///
  final bool supportsLiquidGlass;

  /// Header appearance configuration.
  ///
  final IaHeaderConfiguration header;

  /// Primary button appearance configuration.
  ///
  final IaPrimaryButtonConfiguration primaryButton;

  /// Secondary button appearance configuration.
  ///
  final IaSecondaryButtonConfiguration secondaryButton;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'supportsLiquidGlass': supportsLiquidGlass,
      'header': header.toJson(),
      'primaryButton': primaryButton.toJson(),
      'secondaryButton': secondaryButton.toJson(),
    };
  }
}
