import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gokwik/flutter_gokwik.dart';
import 'package:flutter_gokwik/models/payment_capture_model.dart';
import 'package:flutter_gokwik_example/upi_apps.dart';
import 'package:http/http.dart' as http;
import 'package:upi_pay/upi_pay.dart';
import 'package:upi_pay/src/discovery.dart';
import 'package:upi_pay/src/meta.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Gokwik _gokwik;
  String phoneNumber;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _phoneNumberController;
  GlobalKey<ScaffoldState> _scaffoldKey;

  Future<List<ApplicationMeta>> _getInstalledAppsFuture;

  @override
  void initState() {
    super.initState();
    _getInstalledAppsFuture = UpiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all
    );
    _gokwik = Gokwik();
    _phoneNumberController = TextEditingController(text: "8200921947");
    _scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void rtoAPI() async {
    Map<String, String> headers;
     headers = {
        "appid": "appid",
        "appsecret": "appsecret",
        "Content-Type": "application/json",
        "accept": "application/json"
      };
      print("Hello");
    var response = await http.post(
      Uri.parse("https://sandbox.gokwik.co/v2/rto/predict"),
        headers: headers,
        body: json.encode(_rtodata)
    );

    var decodedResponse = json.decode(response.body);
    print("API RESPONSE/rtoAPI" + response.body.toString());

    //  let dict = ["request_id": self.responseData["request_id"] ?? "", ] as [String : Any]
     /// [Some Dummy Details]
    String requestId = decodedResponse["data"]["request_id"];
    String gokwikOid = "";
    String moid = "zgh067jgklm4f5i2a";
    String mid = "141201";
    String orderType = "non-gk";
    // String orderStatus = decodedResponse["data"]["order_status"];

    /// [Start the Payment]
    _gokwik.initPayment(context,
        production: false, data: GokwikData(requestId, gokwikOid,
            "", moid, mid,"", orderType, "", ""));


    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    void _handleResult(PaymentResponse response) {
      log("main.dart == CALLBACK Result");
      print("object Response");
      print(response.toString());
      if (mounted)
        scaffoldMessenger.showSnackBar(SnackBar(backgroundColor: response.statusCode == 404 ? Colors.red : Colors.black,
            content: new Text(response.statusMessage)));
    }

    _gokwik.on(Gokwik.EVENT_PAYMENT_SUCCESS, _handleResult);
    _gokwik.on(Gokwik.EVENT_PAYMENT_ERROR, _handleResult);
  }

 Map<String, dynamic> _data = {
      "order": {
        "id": "orderId",
        "status": "pending",
        "total": "1.00",
        "subtotal": "1",
        "total_line_items": "1",
        "total_line_items_quantity": "3",
        "total_tax": "0",
        "total_shipping": "0.00",
        "total_discount": "0",
        "payment_details": {"method_id": false ? "upi" : "cod"},
        "billing_address": {
          "first_name": "Test",
          "last_name": "Shop",
          "company": "Test",
          "address_1": "Test",
          "address_2": "",
          "city": "Delhi",
          "state": "DL",
          "postcode": "110092",
          "country": "IN",
          "email": "v@gokwik.co",
          "phone": "91745638356"
        },
        "shipping_address": {
          "first_name": "",
          "last_name": "",
          "company": "",
          "address_1": "",
          "address_2": "",
          "city": "",
          "state": "",
          "postcode": "",
          "country": ""
        },
       
        "line_items": [
          {
            "product_id": 15,
            "variant_id": "12",
            "product": {},
            "name": "Beanie",
            "sku": "woo-beanie",
            "price": 18,
            "quantity": 3,
            "subtotal": "18",
            "total": "54",
            "tax": "0",
            "taxclass": "",
            "taxstat": "taxable",
            "allmeta": [],
            "somemeta": "",
            "type": "line_item",
            "product_url": "https://woo.akash.guru/product/beanie/",
            "product_thumbnail_url": "https://woo.akash.guru/wp-content/uploads/2021/01/beanie-2-150x150.jpg"
          }
        ],
         "customer_ip": "103.82.80.57",
        "customer_user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.16; rv:86.0) Gecko/20100101 Firefox/86.0",
        "source": "aaa",
        "promo_code": "aaa",
        "order_notes": "[]"
      }
    };
      Map<String, dynamic> _rtodata = {
          "customer" : {
              "age":21,
              "gender":"male",
              "wallet_balance":100.00,
              "customer_since":25
              },
            "order": {
                "order_date":"2021-06-09T11:56:33.169Z",
                "subtotal":7400,
                "total_line_items":2,
                "total_line_items_quantity":3,
                "total_tax":150,
                "total_shipping":50,
                "total_discount":500,
                "total":7100,
                "promo_code":"abc_code",
                "billing_address": { 
                  "address_1":"Test",
                     "address_2":"",
                     "city":"Delhi",
                     "state":"DL",
                     "postcode":"110092",
                     "type":"home"
                     },
                "shipping_address": { 
                  "first_name":"Rajesh",
                     "last_name":"Chopra",
                     "company":"HCl",
                     "address_1":"ABC road",
                     "address_2":"smart city",
                     "city":"Delhi",
                     "state":"DL",
                     "postcode":"110092",
                     "email":"xyz@exampal.com",
                     "phone":"99XXXXXX99",
                     "type":"home"},
            "line_items": [
              {
            "product_id":"avc",
            "line_item_id":"eew",
            "item_brand":"nike",
            "item_rating":3.2,
            "item_size":"xl",
            "item_color":"red",
            "is_exclusive":true,
            "item_weight":10,
            "item_length":10,
            "item_breadth":1,
            "item_height":10,
            "item_discount":100,
            "variant_id":"Adc235",
            "name":"facewash",
            "sku":"Sku32",
            "price":3000.00,
            "quantity":1,
            "subtotal":2500.00,
            "total":2450,
            "tax":50,
            "product_url":"abc.com/ttt",
            "product_thumbnail_url":"abc.com/ttt/tgf",
            "article_price":1000.00,
            "target_group":"MEN",
            "sub_category":"SPORT_SHOES",
            "major_category":"SHOES"
        },{"product_id":"avc",
           "line_item_id":"eew",
           "item_brand":"nike",
           "item_rating":3.2,
           "item_size":"xl",
           "item_color":"red",
           "is_exclusive":true,
           "item_weight":10,
           "item_length":10,
           "item_breadth":1,
           "item_height":10,
           "item_discount":100,
           "variant_id":"Adc235",
           "name":"facewash",
           "sku":"Sku32",
           "price":3000.00,
           "quantity":2,
           "subtotal":5000.00,
           "total":4950,
           "tax":50,
           "product_url":"abc.com/ttt",
           "product_thumbnail_url":"abc.com/ttt/tgf",
           "article_price":1000.00,
           "target_group":"MEN",
           "sub_category":"SPORT_SHOES",
           "major_category":"SHOES"}
           ],
            "session" : { 
              "source":"string",
              // "session_history":{
              //     "https://www.gokwik.co/",
              //     "https://www.gokwik.co/contact"
              // },
              "session_length":45,
              "total_pages_viewed":5,
              "customer_ip":"192.168.96.1",
              "customer_user_agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.16; rv:86.0) Gecko/20100101 Firefox/86.0"
            }
            
        
    }};

  void createOrder(bool isUPI, String upiAppName) async {
    var rng = new math.Random();
    String orderId = (rng.nextInt(900000) + 100000).toString();

    if(isUPI){
      _prefs.then((value) {
        value.setString('rID', orderId);
      });
    }

    if (upiAppName == 'update'){
      _prefs.then((value){
        orderId = value.getString('rID');
        isUPI = false;
      });
    }

    log(orderId);

    Map<String, dynamic> _data = {
      "order": {
        "id": orderId,
        "status": "pending",
        "total": "1.00",
        "subtotal": "1",
        "total_line_items": "1",
        "total_line_items_quantity": "3",
        "total_tax": "0",
        "total_shipping": "0.00",
        "total_discount": "0",
        "payment_details": {"method_id": isUPI ? "upi" : "cod"},
        "billing_address": {
          "first_name": "Test",
          "last_name": "Shop",
          "company": "Test",
          "address_1": "Test",
          "address_2": "",
          "city": "Delhi",
          "state": "DL",
          "postcode": "110092",
          "country": "IN",
          "email": "v@gokwik.co",
          "phone": phoneNumber.toString()
        },
        "shipping_address": {
          "first_name": "",
          "last_name": "",
          "company": "",
          "address_1": "",
          "address_2": "",
          "city": "",
          "state": "",
          "postcode": "",
          "country": ""
        },
        "customer_ip": "103.82.80.57",
        "customer_user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.16; rv:86.0) Gecko/20100101 Firefox/86.0",
        "line_items": [
          {
            "product_id": 15,
            "variant_id": "12",
            "product": {},
            "name": "Beanie",
            "sku": "woo-beanie",
            "price": 18,
            "quantity": 3,
            "subtotal": "18",
            "total": "54",
            "tax": "0",
            "taxclass": "",
            "taxstat": "taxable",
            "allmeta": [],
            "somemeta": "",
            "type": "line_item",
            "product_url": "https://woo.akash.guru/product/beanie/",
            "product_thumbnail_url": "https://woo.akash.guru/wp-content/uploads/2021/01/beanie-2-150x150.jpg"
          }
        ],
        "source": "aaa",
        "promo_code": "aaa",
        "order_notes": "[]"
      }
    };

    Map<String, String> headers;
    if(!isUPI && upiAppName == 'otp') {
      headers = {
        "appid": "appid",
        "appsecret": "appsecret",
        "Content-Type": "application/json"
      };
    } else if (!isUPI && upiAppName == '') {
      headers = {
        "appid": "appid",
        "appsecret": "appsecret",
        "Content-Type": "application/json"
      };
    }else{
      headers = {
        "appid": "appid",
        "appsecret": "appsecret",
        "Content-Type": "application/json"
      };
    }

    var response = await http.post(
      Uri.parse("https://sandbox.gokwik.co/v1/order/create"),
        headers: headers,
        body: json.encode(_data)
    );
    print("Hello there");
    var decodedResponse = json.decode(response.body);
    print("API RESPONSE/create" + response.body.toString());

    /// [Some Dummy Details]
    String requestId = decodedResponse["data"]["request_id"];
    String gokwikOid = decodedResponse["data"]["gokwik_oid"];
    String total = decodedResponse["data"]["total"];
    String moid = decodedResponse["data"]["moid"];
    String mid = decodedResponse["data"]["mid"];
    // String phone = decodedResponse["data"]["phone"];
    String orderType = decodedResponse["data"]["order_type"];
    String orderStatus = decodedResponse["data"]["order_status"];

    /// [Start the Payment]
    _gokwik.initPayment(context,
        production: false, data: GokwikData(requestId, gokwikOid,
            total, moid, mid, "",orderType, upiAppName, orderStatus));


    ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    void _handleResult(PaymentResponse response) {
      log("main.dart == CALLBACK Result");
      print("object Response");
      print(response.toString());
      if (mounted)
        scaffoldMessenger.showSnackBar(SnackBar(backgroundColor: response.statusCode == 404 ? Colors.red : Colors.black,
            content: new Text(response.statusMessage)));
    }

    _gokwik.on(Gokwik.EVENT_PAYMENT_SUCCESS, _handleResult);
    _gokwik.on(Gokwik.EVENT_PAYMENT_ERROR, _handleResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 10.0,
        title: const Text('GoKwik Flutter SDK'),
      ),
      body: FutureBuilder(
        future: _getInstalledAppsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshotData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        phoneNumber = val;
                      },
                      style: TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          labelText: "Phone number",  
                          labelStyle: TextStyle(fontWeight: FontWeight.normal),
                          border: OutlineInputBorder(borderSide: new BorderSide(color: Colors.indigo))),
                    ),
                    
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        //color: Colors.indigoAccent,
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          createOrder(true, "");
                        },
                        child: Text(
                          "Pay through UPI",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        //color: Colors.indigoAccent,
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          createOrder(false, "otp");
                        },
                        child: Text(
                          "COD with OTP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        //color: Colors.indigoAccent,
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          createOrder(false, "");
                        },
                        child: Text(
                          "COD without OTP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        //color: Colors.indigoAccent,
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          createOrder(false, "update");
                        },
                        child: Text(
                          "Update UPI order to COD",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),SizedBox(height: 16.0),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        //color: Colors.indigoAccent,
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          rtoAPI();
                        },
                        child: Text(
                          "Non-GK Order Flow",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
        },
      )
    );
  }
}
