import Flutter
import UIKit
import GokwikUpi

public class SwiftFlutterGokwikPlugin: NSObject, FlutterPlugin, GokwikPaymentStatusDelegate {
    
    var complitionHandler: FlutterResult!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_gokwik", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterGokwikPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> Void {
        let arguments = call.arguments as? NSDictionary
        switch(call.method) {
        case "HandlePayment":
            print(arguments?["data"]! ?? "")
            complitionHandler = result
            let params : [String : Any] = arguments?["data"] as! [String : Any]
            let env :  Bool = params["environment"] as! Bool
            let gwPaymnet = GokwikCheckout(production: env, delegate: self)
            gwPaymnet.openCart(createData: params)
        case "canLaunch":
            let uri = (arguments!["uri"] as? String)!
            result(self.canLaunch(uri: uri))
            return
        case "launch":
            let uri = (arguments!["uri"] as? String)!
            self.launchUri(uri: uri, result: result)
            result(result)
            return
        default:
            result(FlutterMethodNotImplemented)
            return
        }
    }
    
    public func gokwikPayment(status: Bool, data: [String : Any]) {
        var resultData : [String:Any] = [:]
        resultData["status"] = status
        resultData["data"] = data
        //      self.navigationController?.navigationBar.isHidden = true
        complitionHandler(resultData)
    }
    
    private func canLaunch(uri: String) -> Bool {
        let url = URL(string: uri)
        return UIApplication.shared.canOpenURL(url!)
    }
    
    private func launchUri(uri: String, result: @escaping FlutterResult) -> Bool {
        if(canLaunch(uri: uri)) {
            let url = URL(string: uri)
            if #available(iOS 10, *) {
                UIApplication.shared.open(url!, completionHandler: { (ret) in
                    result(ret)
                })
            } else {
                result(UIApplication.shared.openURL(url!))
            }
        }
        return false
    }
    
    
}
