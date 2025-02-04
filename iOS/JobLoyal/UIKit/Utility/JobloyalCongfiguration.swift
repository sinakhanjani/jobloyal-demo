//
//  Config.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/13/1399 AP.
//

import Foundation

enum JobloyalCongfiguration: String, Codable {
    
    struct Time {
        static public var requestLifeTime: Int = 300
        static public var userTimePaying: Int = 300
        // this is for request time fetch from server every X seconds.
        static public let fetchOrderDuration: Double = 20
        static public let fechJobRequestDuration: Double = 15
    }
    
    struct Notification {
        static public let dailyUpdateJob: LocalNotification = {
            // send notificaiton every day at 7 AM.
            let title = "GetYourJobOnline".localized()
            let body = "jobOnlineBody".localized()
            
            return LocalNotification(title: title, body: body, identifier: "jobber.online.job")
        }()
        
        static public var dailyUpdateJobStatus: Bool {
            get {
                UserDefaults.standard.bool(forKey: "dailyUpdateJobStatus")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "dailyUpdateJobStatus")
            }
        }
    }
    
    struct TermAndCondition {
        static public var url: String {
            let currentLocale = Locale.preferredLanguages[0]
            // current region
            var region = currentLocale.components(separatedBy: "-").first ?? "en"
            // set france language for other region
            region = (region != "en") ? "fr":"en"
            
            return "https://api.jobloyal.com/app/terms?dark=\(String(describing: TermAndCondition.isDark))&lang=\(region)"
        }
        static public var isDark = true
    }
    
    struct StripeBank {
        // SDK Documents:
        // https://stripe.com/docs/payments/accept-a-payment?platform=ios
        // {{url}}/user/payment/check-pay: Generic<EMPTYMODEl>
        // {{url}}/user/payment/pay: Generic<MODEL>
        ///payment/pay::: paid: true or false (true: anjam shode -> safe refresh, false: stripeBank baz konam.)
        static private let _testPublicKey = "pk_test_51IMohRJeuajFZKTVa7J1rLt2CHDg4HSPv2Dc4XAhztKt0rZX80Sfykgy7kXh2qn3WQO4hOpuS0Megr003D1YCe4900IIO5sBUu"
        static private let _livePublicKey = "pk_live_51IMohRJeuajFZKTVB2RuslwExTdoXHhFIoeRpodHY3xomsJkC8MDxin6tIUkFnj4vPpEcEcAPXY6NDgs75lUPHwY00COGmm5qn"

        static public var publicKey: String { _livePublicKey }
    }
    
    case baseURL = "https://api.jobloyal.com/v1"
    case defaultImageTitle = "default_image_cover"
    
    var value: String { rawValue }
}
