import 'package:flutter_gokwik/models/cod_payment_model.dart';

class CODResponse {
  final CODPaymentResponse paymentResponse;
  final bool merchantUserVerified;

  CODResponse(this.paymentResponse, this.merchantUserVerified);
}
