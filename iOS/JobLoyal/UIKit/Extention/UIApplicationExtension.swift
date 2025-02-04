//
//  UIApplicationExtension.swift
//  JobLoyal
//
//  Created by Sina khanjani on 3/30/1400 AP.
//

import UIKit
import RestfulAPI

extension UIApplication {
    var rootViewController: UIViewController? { windows.first?.rootViewController }

    static var appVersion: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String }
    static var appBuild: String { Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String }
    static var deviceID: String? { UIDevice.current.identifierForVendor?.uuidString }
    static var deviceType: String { UIDevice().model }
    static var fcmToken: String {
        get {
            UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        }
        set {
            let token = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
            // check is token changed from firebase
            if (token != "") && (token == newValue) {
                // override data here
                return
            } else if (token != "")  && (token != newValue) {
                // new token register from fcm here
                // if user isloggin and fcm token is not ""
                if Authentication.user.isLogin {
                    registerDeviceRequest(auth: .user)
                }
                // if jobber isloggin and fcm token is not ""
                if Authentication.jobber.isLogin {
                    registerDeviceRequest(auth: .user)
                }
                UserDefaults.standard.setValue(newValue, forKey: "fcmToken")
                return
            } else if (token == "") && (newValue != "") {
                // when application begin
                UserDefaults.standard.setValue(newValue, forKey: "fcmToken")
                return
            }
        }
    }
    
    static private func registerDeviceRequest(auth: Authentication) {
        let body = SendRegisterDeviceModel(device_id: UIApplication.deviceID ?? "-", device_type: "ios", fcm: UIApplication.fcmToken, extra: UIApplication.deviceType)
        let path = auth == .jobber ? "jobber":"user"
        
        RestfulAPI<SendRegisterDeviceModel,Generic<EMPTYMODEL>>.init(path: "/\(path)/device/add")
            .with(auth: auth)
            .with(method: .POST)
            .with(body: body)
            .sendURLSessionRequest { _ in
                //
            }
    }
}
