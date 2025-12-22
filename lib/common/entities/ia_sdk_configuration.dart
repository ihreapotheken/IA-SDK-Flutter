/// Basic definition for the ia.de SDK client configuration.
///
class IaSdkConfiguration {
  /// Generates an instance of the ia.de SDK client configuration.
  ///
  /// For more information, see [accessKey], [clientId], and [serverEnvironment].
  ///
  IaSdkConfiguration({
    required this.accessKey,
    required this.clientId,
    required this.serverEnvironment,
    this.shouldFetchThemeFromRemote = false,
    IaFooterConfiguration? footer,
    IaInitializationConfiguration? initialization,
  })  : footer = footer ?? IaFooterConfiguration(),
        initialization = initialization ?? IaInitializationConfiguration();

  /// Key used to authenticate the client setup with the backend service.
  ///
  /// Provided to clients by the ia.de team on an individual basis.
  ///
  final String accessKey;

  /// Client identifier used to determine the pharmacy channel specification.
  ///
  /// Provided to clients by the ia.de team on an individual basis.
  ///
  final String clientId;

  /// Selected server environment specification.
  ///
  /// Currently only available with the iOS platform.
  ///
  /// See [IaSdkConfigServerEnvironment] for further information.
  ///
  final IaSdkConfigServerEnvironment serverEnvironment;

  /// Whether to fetch theme configuration from remote server.
  ///
  final bool shouldFetchThemeFromRemote;

  /// Footer configuration options.
  ///
  final IaFooterConfiguration footer;

  /// Initialization configuration options.
  ///
  final IaInitializationConfiguration initialization;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'accessKey': accessKey,
      'clientId': clientId,
      'serverEnvironment': serverEnvironment.name,
      'shouldFetchThemeFromRemote': shouldFetchThemeFromRemote,
      'footer': footer.toJson(),
      'initialization': initialization.toJson(),
    };
  }
}

/// Identifier for the ia.de server environments.
///
/// 3 different server environments are set up: DEV, QA, and PROD.
///
/// The `development` and `staging` environments are set up for internal testing
/// and are accessible with VPN only, while the `production` environment is the
/// production-ready environment to which the end-users have access.
///
/// VPN access can be provided by the ia.de team on inquiry.
///
enum IaSdkConfigServerEnvironment {
  /// https://ihreapotheken.de/
  ///
  /// Production / live server environment.
  ///
  production,

  /// https://qa.ihreapotheken.de/
  ///
  /// QA server environment, requires VPN for access.
  ///
  staging,

  /// https://dev.ihreapotheken.de/
  ///
  /// DEV server environment, requires VPN for access.
  ///
  development,
}

/// Configuration options for SDK initialization behavior.
///
class IaInitializationConfiguration {
  /// Generates an instance of initialization configuration.
  ///
  IaInitializationConfiguration({
    this.shouldShowIndicator = true,
    IaPrerequisitesConfiguration? prerequisites,
  }) : prerequisites = prerequisites ?? IaPrerequisitesConfiguration();

  /// Whether to show a loading indicator during initialization.
  ///
  final bool shouldShowIndicator;

  /// Prerequisites configuration options.
  ///
  final IaPrerequisitesConfiguration prerequisites;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'shouldShowIndicator': shouldShowIndicator,
      'prerequisites': prerequisites.toJson(),
    };
  }
}

/// Configuration options for SDK prerequisites.
///
class IaPrerequisitesConfiguration {
  /// Generates an instance of prerequisites configuration.
  ///
  IaPrerequisitesConfiguration({
    this.shouldShowIndicator = true,
    this.isCancellable = false,
    this.isAnimated = true,
    this.runLegalIfNeeded = true,
    this.runOnboardingIfNeeded = true,
    this.runApofinderIfNeeded = true,
  });

  /// Whether to show a loading indicator during prerequisites.
  ///
  final bool shouldShowIndicator;

  /// Whether the prerequisites flow can be cancelled.
  ///
  final bool isCancellable;

  /// Whether to show animations during prerequisites flow.
  ///
  final bool isAnimated;

  /// Whether to run legal documents flow if needed.
  ///
  final bool runLegalIfNeeded;

  /// Whether to run onboarding flow if needed.
  ///
  final bool runOnboardingIfNeeded;

  /// Whether to run pharmacy finder (Apofinder) flow if needed.
  ///
  final bool runApofinderIfNeeded;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'shouldShowIndicator': shouldShowIndicator,
      'isCancellable': isCancellable,
      'isAnimated': isAnimated,
      'runLegalIfNeeded': runLegalIfNeeded,
      'runOnboardingIfNeeded': runOnboardingIfNeeded,
      'runApofinderIfNeeded': runApofinderIfNeeded,
    };
  }
}

/// Configuration options for SDK footer buttons.
///
class IaFooterConfiguration {
  /// Generates an instance of footer configuration.
  ///
  IaFooterConfiguration({
    this.shouldShowDataProcessing = true,
    this.shouldShowAppSettings = true,
    this.shouldShowImprint = true,
  });

  /// Whether to show the data processing button in the footer.
  ///
  final bool shouldShowDataProcessing;

  /// Whether to show the app settings button in the footer.
  ///
  final bool shouldShowAppSettings;

  /// Whether to show the imprint button in the footer.
  ///
  final bool shouldShowImprint;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'shouldShowDataProcessing': shouldShowDataProcessing,
      'shouldShowAppSettings': shouldShowAppSettings,
      'shouldShowImprint': shouldShowImprint,
    };
  }
}
