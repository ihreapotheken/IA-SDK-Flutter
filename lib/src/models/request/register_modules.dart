part of '../../core.dart';

class _RequestModelRegisterModules implements IaBaseRequest {
  _RequestModelRegisterModules({
    required this.modules,
  });

  final List<IaBase> modules;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'modules': modules.map(
        (module) {
          return module.module.name;
        },
      ).toList(),
    };
  }
}
