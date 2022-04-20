import 'package:flutter/material.dart';
import 'package:upi_pay/src/applications.dart';

class UpiAppList extends StatelessWidget {

  const UpiAppList({
    Key key,
    @required this.snapshotData,
    @required this.onPressed
  }) : super(key: key);

  final AsyncSnapshot snapshotData;
  final ValueSetter<String> onPressed;

  @override
  Widget build(BuildContext context) {
    if(snapshotData.hasData && snapshotData.data.length > 0) {
      var verifiedUpiAppList = <UpiApplication>[];
      for (int i = 0; i < snapshotData.data.length; ++i) {
        String upiApp = snapshotData.data[i].upiApplication.discoveryCustomScheme.toLowerCase() ?? "";
        if (upiApp == "gpay" || upiApp == "phonepe" || upiApp == "paytm") {
          verifiedUpiAppList.add(snapshotData.data[i].upiApplication);
        }
      }
      return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: 24.0),
        physics: BouncingScrollPhysics(),
        itemCount: verifiedUpiAppList.length,
        itemBuilder: (context, index) {
          var upiApp = verifiedUpiAppList[index];
          return Container(
            key: UniqueKey(),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 16.0),
              SizedBox(
                width: double.maxFinite,
                height: 32,
                child: ElevatedButton(
                  //color: Colors.indigoAccent,
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    onPressed(upiApp.discoveryCustomScheme);
                  },
                  child: Text(
                    'Pay with ${upiApp.getAppName()}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ]),
          );
        });
    }
    return Container();
  }

}