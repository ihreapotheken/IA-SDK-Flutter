part of '../../impl.dart';

class _RequestModelSetHostAppLogFilePath implements IaBaseRequest {
  _RequestModelSetHostAppLogFilePath({
    required this.path,
  });

  final String path;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'path': path,
    };
  }
}
