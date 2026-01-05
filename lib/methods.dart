part of 'sdk.dart';

/// Collection of method identifiers specified for client integration.
///
enum _IaSdkPlatformMethods {
  /// Used to allocate ia.de SDK resources.
  ///
  /// Must be invoked before any of the available SDK methods or fields are utilised.
  ///
  initIaSdk,

  /// Registers SDK modules for use in the application.
  ///
  register,

  /// Selects a pharmacy by providing an identifier.
  ///
  setPharmacyId,

  /// Resets the state of user cart, clearing any added products or prescriptions.
  ///
  clearCart,

  /// Forwards the client personal information to the ia.de library for checkout purposes.
  ///
  setGuestUserData,

  /// Resets the user data and onboarding status (pharmacy selection, user consents statuses).
  ///
  logout,

  /// Places a new activity object into the navigation stack.
  ///
  /// Defined with the ia.de Flutter plugin native bindings.
  ///
  launchRoute,

  /// Forwards a collection of prescription objects with the ia.de checkout services.
  ///
  transferPrescriptions,

  /// Closes any overlaying ia.de screen contents.
  ///
  finishAllActivities;

  /// Verifies [_platformChannel] argument input.
  ///
  void _verifyArgumentInput(
    dynamic arguments, {
    required Type? argumentType,
    List<({String name, Type type, bool nullable})>? requiredMapFields,
  }) {
    if (argumentType == null) return;
    final exception = Exception(
      'Argument ${arguments.runtimeType} is not of type $argumentType:\n$arguments',
    );
    switch (argumentType) {
      case const (String):
        if (arguments is! String) throw exception;
        break;
      case const (bool):
        if (arguments is! bool) throw exception;
        break;
      case const (int):
        if (arguments is! int) throw exception;
        break;
      case const (double):
        if (arguments is! double) throw exception;
        break;
      case const (Uint8List):
        if (arguments is! Uint8List) throw exception;
        break;
      case const (Map):
        if (arguments is! Map) throw exception;
        if (requiredMapFields == null) {
          throw Exception(
            'Required map fields must be provided for verification.',
          );
        }
        for (final requiredField in requiredMapFields) {
          final value = arguments[requiredField.name];
          if (value == null && !requiredField.nullable) {
            throw Exception(
              'Field ${requiredField.name} must be submitted with '
              'argument declaration:\n---\n$requiredField',
            );
          }
        }
        break;
      default:
        throw Exception(
          'Argument type $argumentType not implemented.',
        );
    }
  }

  /// Invokes any specified native method using a [MethodChannel] object, returning the result.
  ///
  Future<T?> invoke<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    try {
      switch (this) {
        case _IaSdkPlatformMethods.initIaSdk:
          _verifyArgumentInput(
            arguments,
            argumentType: Map,
            requiredMapFields: [
              (
                name: 'accessKey',
                type: String,
                nullable: false,
              ),
              (
                name: 'clientId',
                type: String,
                nullable: false,
              ),
              (
                name: 'serverEnvironment',
                type: String,
                nullable: false,
              ),
            ],
          );
          break;
        case _IaSdkPlatformMethods.register:
          _verifyArgumentInput(
            arguments,
            argumentType: Map,
            requiredMapFields: [
              (
                name: 'modules',
                type: List<String>,
                nullable: false,
              ),
            ],
          );
          break;
        case _IaSdkPlatformMethods.setPharmacyId:
          _verifyArgumentInput(
            arguments,
            argumentType: Map,
            requiredMapFields: [
              (
                name: 'pharmacyId',
                type: String,
                nullable: false,
              ),
            ],
          );
          break;
        case _IaSdkPlatformMethods.clearCart:
          break;
        case _IaSdkPlatformMethods.setGuestUserData:
          _verifyArgumentInput(
            arguments,
            argumentType: Map,
            requiredMapFields: [
              (
                name: 'salutation',
                nullable: false,
                type: String,
              ),
              (
                name: 'firstName',
                nullable: false,
                type: String,
              ),
              (
                name: 'lastName',
                nullable: false,
                type: String,
              ),
              (
                name: 'email',
                nullable: false,
                type: String,
              ),
              (
                name: 'phoneNumberCountryCode',
                nullable: true,
                type: String,
              ),
              (
                name: 'phoneNumberWithoutCountryCode',
                nullable: true,
                type: String,
              ),
            ],
          );
          break;
        case _IaSdkPlatformMethods.logout:
          break;
        case _IaSdkPlatformMethods.launchRoute:
          _verifyArgumentInput(
            arguments,
            argumentType: String,
          );
          break;
        case _IaSdkPlatformMethods.transferPrescriptions:
          _verifyArgumentInput(
            arguments,
            argumentType: Map,
            requiredMapFields: [
              (
                name: 'images',
                type: Iterable<Uint8List>,
                nullable: true,
              ),
              (
                name: 'pdfs',
                type: Iterable<Uint8List>,
                nullable: true,
              ),
              (
                name: 'codes',
                type: Iterable<String>,
                nullable: true,
              ),
            ],
          );
          break;
        case _IaSdkPlatformMethods.finishAllActivities:
          break;
      }
      return await publicApi._channel.invokeMethod(
        name,
        arguments,
      );
    } catch (e) {
      throw Exception(
        'An error occurred invoking the $name method with:\n---\n$arguments\n---\n$e',
      );
    }
  }
}
