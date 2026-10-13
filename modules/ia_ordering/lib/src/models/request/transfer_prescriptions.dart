part of '../../impl.dart';

class _RequestModelTransferPrescriptions implements IaBaseRequest {
  _RequestModelTransferPrescriptions({
    this.images,
    this.pdfs,
    this.codes,
    this.orderId,
    required this.finishAction,
    required this.showActivityIndicator,
  });

  final Iterable<Uint8List>? images;

  final Iterable<({Uint8List data, IaPrescriptionInsuranceType insuranceType})>? pdfs;

  final Iterable<String>? codes;

  final String? orderId;

  final IaTransferPrescriptionsFinishAction finishAction;

  final bool showActivityIndicator;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'images': images,
      'pdfs': pdfs?.map((pdf) => {
        'data': pdf.data,
        'insuranceType': pdf.insuranceType.rawValue,
      }).toList(),
      'codes': codes,
      'orderId': orderId,
      'finishAction': finishAction.name,
      'showActivityIndicator': showActivityIndicator,
    };
  }
}
