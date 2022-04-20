import 'package:eventify/eventify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gokwik/models/cod_response.dart';
import 'package:flutter_gokwik/models/payment_capture_model.dart';
import 'package:flutter_gokwik/models/upi_payment_model.dart';

// export 'package:upi_pay/src/api.dart' show UpiPay;

class Gokwik {
  // Event names
  static const EVENT_PAYMENT_SUCCESS = 'SUCCESS';
  static const EVENT_PAYMENT_ERROR = 'ERROR';

  // Method Channels
  static const MethodChannel _channel = const MethodChannel('flutter_gokwik');

  late EventEmitter _eventEmitter;

  var verifyModel;
  Gokwik() {
    _eventEmitter = EventEmitter();
  }

  void initPayment(BuildContext context,
      {required GokwikData data, required bool production}) async {
    if (verifyCreateOrderData(data)) {
        try {
          _channel.invokeMethod('HandlePayment', <String, dynamic>{
            "data": {
              "request_id": data.requestId,
              "gokwik_oid": data.gokwikOid,
              "total": data.total,
              "moid": data.moid,
              "mid": data.mid,
              // "phone": data.phone,
              "order_status": data.orderStatus,
              "order_type": data.orderType,
              "otp_verify" : true,
              // "upi_app": data.upiAppName,
              // "upi_app": data.upiAppName,
              // "upi_app_package": data.upiAppName,
              "environment" : production
            }
          }).then((value) async {
            print("$value");
            if(value["status"]==true){
              _eventEmitter.emit(
            Gokwik.EVENT_PAYMENT_SUCCESS, null, PaymentResponse(statusCode: 200, statusMessage: value.toString()));
            }else{
              _eventEmitter.emit(
            Gokwik.EVENT_PAYMENT_ERROR, null, PaymentResponse(statusCode: 404, statusMessage: "Canceled by User"));
            }
            _eventEmitter.clear();
          });
        } on PlatformException catch (e) {
          print("Failed to get response: '${e.message}'.");
        }
    }
  }

  bool verifyCreateOrderData(GokwikData orderData) {
    if (orderData == null) {
      handleFailureResponse('invalid createData prop');
      return false;
    } else if (orderData.requestId == null) {
      handleFailureResponse('invalid request_id param in createData prop');
      return false;
    } else if (orderData.gokwikOid == null) {
      handleFailureResponse('invalid gokwik_oid param in createData prop');
      return false;
    } else if (orderData.orderType == null) {
      handleFailureResponse('invalid order_status param in createData prop');
      return false;
    } else if (orderData.total == null) {
      handleFailureResponse('invalid total param in createData prop');
      return false;
    } else if (orderData.moid == null) {
      handleFailureResponse('invalid moid in createData prop');
      return false;
    } else if (orderData.mid == null) {
      handleFailureResponse('invalid mid in createData prop');
      return false;
    // } else if (orderData.phone == null) {
    //   handleFailureResponse('invalid phone in createData prop');
    //   return false;
    }
    return true;
  }

  void handleOtpResponse(CODResponse _codResponse) {
    if (_codResponse.merchantUserVerified == false) {
      if (_codResponse.paymentResponse == null) {
        _eventEmitter.emit(
            Gokwik.EVENT_PAYMENT_ERROR, null, "Canceled by user");
        _eventEmitter.clear();
        return;
      } else {
        if (_codResponse.paymentResponse.statusCode == 200) {
          _eventEmitter.emit(
              Gokwik.EVENT_PAYMENT_SUCCESS, null, _codResponse.paymentResponse);
          _eventEmitter.clear();
          return;
        } else {
          _eventEmitter.emit(Gokwik.EVENT_PAYMENT_ERROR, null,
              _codResponse.paymentResponse.statusMessage);
          _eventEmitter.clear();
          return;
        }
      }
    } else {
      _eventEmitter.emit(Gokwik.EVENT_PAYMENT_SUCCESS, null,
          PaymentResponse(statusCode: 200, statusMessage: "Mercent Verified"));
      _eventEmitter.clear();
      return;
    }
  }

  void handleUpiPaymentResponse(UPIPaymentResponse _paymentResponse, String errorMeg) {
        print("objectobjectobject");
    if (_paymentResponse == null) {
      _eventEmitter.emit(Gokwik.EVENT_PAYMENT_ERROR, null, "Canceled by user");
      _eventEmitter.clear();
      return;
    } else {
      if (_paymentResponse.statusCode == 200 &&
          _paymentResponse.data!.paymentStatus == 'PAID') {
        _eventEmitter.emit(
            Gokwik.EVENT_PAYMENT_SUCCESS, null, _paymentResponse);
        _eventEmitter.clear();
        return;
      } else {
        _eventEmitter.emit(
            Gokwik.EVENT_PAYMENT_ERROR, null, _paymentResponse.statusMessage);
        _eventEmitter.clear();
        return;
      }
    }
  }

  /// Registers event listeners for payment events. [Handle Callbacks]
  void on(String event, Function handler) {
    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
  }

  void handleFailureResponse(String errorMsg) {
    _eventEmitter.emit(Gokwik.EVENT_PAYMENT_ERROR, null, errorMsg);
  }
}

class GokwikData {
  final String requestId;
  final String gokwikOid;
  final String total;
  final String moid;
  final String mid;
  final String phone;
  final String orderType;
  final String upiAppName;
  final String orderStatus;

  GokwikData(this.requestId, this.gokwikOid, this.total, this.moid, this.mid,
      this.phone, this.orderType, this.upiAppName, this.orderStatus);
}
