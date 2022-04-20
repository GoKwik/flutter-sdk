import 'package:flutter_gokwik/models/payment_capture_model.dart';

class CODPaymentResponse extends PaymentResponse {
  Data? data;

  CODPaymentResponse({this.data});

  CODPaymentResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['statusMessage'] = this.statusMessage;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? phone;
  String? auth_token;
  String? order_type;

  Data({this.phone, this.auth_token, this.order_type});

  Data.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    auth_token = json['auth_token'];
    order_type = json['order_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['auth_token'] = this.auth_token;
    data['order_type'] = this.order_type;
    return data;
  }
}
