part of '../../core.dart';

class _RequestModelRegisterModules implements IaBaseRequest {
  _RequestModelRegisterModules({
    required this.modules,
  });

  final List<IaBaseModule> modules;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'modules':
          [
            IaBaseModule.integrations,
            IaBaseModule.apofinder,
            IaBaseModule.appointments,
            ...modules,
          ].map(
            (module) {
              return module.name;
            },
          ).toList(),
    };
  }
}
