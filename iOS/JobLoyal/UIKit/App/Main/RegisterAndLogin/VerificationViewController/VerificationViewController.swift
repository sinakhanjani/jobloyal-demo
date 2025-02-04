//
//  VerificationViewController.swift
//  JobLoyal
//
//  Created by Sina khanjani on 2/31/1400 AP.
//

import UIKit
import RestfulAPI

class VerificationViewController: InterfaceViewController {
    
    private let toJobberIdentityViewControllerSegue = "toJobberIdentityTableViewControllerSegue"
    private let toUserIdentityViewControllerSegue = "toUserIdentityTableViewControllerSegue"
    
    private let numberOfVerificationDigits = 6

    @IBOutlet weak var digitEntryView: DigitEntryView!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nextButton: AppButton!
    
    private let elapsedTimeInSecond = 120
    private var timer: TimerHelper?
    
    public var phoneNumber: String?
    public var auth: Authentication = .none

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    // MARK: METHOD
    private func updateUI() {
        setupDigitEntryView()
        setupTimer()
        phoneLabel.text = phoneNumber
    }
    
    private func setupTimer() {
        resendButton.isEnabled = false
        resendButton.setTitleColor(.secondaryLabel, for: .normal)
        resendButton.setTitle("02:00", for: .normal)
        
        timer = nil
        timer = TimerHelper(elapsedTimeInSecond: elapsedTimeInSecond)
        timer?.start { [weak self] (secend,minute) in
            self?.resendButton.setTitle("\(minute):\(secend)", for: .normal)
            if self?.resendButton.title(for: .normal) == "00:00" {
                self?.resendButton.setTitle("Resend".localized(), for: .normal)
                self?.resendButton.setTitleColor(.heavyBlue, for: .normal)
                self?.resendButton.isEnabled = true
            }
        }
    }

    private func setupDigitEntryView() {
        digitEntryView.numberOfDigits = numberOfVerificationDigits
        digitEntryView.digitColor = UIColor.heavyBlue
        digitEntryView.digitFont = UIFont.avenirNextMedium(size: 22)
        digitEntryView.digitCornerStyle = .circle
        digitEntryView.digitBorderWidth = 2
        digitEntryView.digitCornerStyle = .radius(4)
        digitEntryView.digitBorderColor = UIColor.tertiarySystemFill
        digitEntryView.nextDigitBorderColor = UIColor.heavyBlue
        digitEntryView.delegate = self
        digitEntryView.becomeFirstResponder()
    }
    
    // MARK: - IBACTION
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let phoneNumber = phoneNumber else { return }
        let checkOTP = SendCheckOTP(phoneNumber: phoneNumber, code: digitEntryView.text)
        let network = RestfulAPI<SendCheckOTP,Generic<RCCheckOTP>>.init(path: "/common/otp/check")
            .with(method: .POST)
            .with(body: checkOTP)

        handleRequestByUI(network, disable: [nextButton]) { [weak self] (response) in
            if let checkToken = response.data?.token {
                Auth.shared.none.register(with: checkToken)
                self?.checkUserResgistrationStatus()
            }
        }
    }

    private func checkUserResgistrationStatus() {
        
        func registerForNewUser() {
            switch self.auth {
            case .none:
                break
            case .user:
                // To user identity
                performSegue(withIdentifier: toUserIdentityViewControllerSegue, sender: nil)
            case .jobber:
                // To jobber identity
                performSegue(withIdentifier: toJobberIdentityViewControllerSegue, sender: nil)
            }
        }
        
        func registerDeviceRequest(auth: Authentication) {
            let path = auth == .jobber ? "jobber":"user"
            let body = SendRegisterDeviceModel(device_id: UIApplication.deviceID ?? "SIMULATOR", device_type: "ios", fcm: UIApplication.fcmToken, extra: UIApplication.deviceType)
            let network = RestfulAPI<SendRegisterDeviceModel,Generic<EMPTYMODEL>>.init(path: "/\(path)/device/add")
                .with(auth: auth)
                .with(method: .POST)
                .with(body: body)

            handleRequestByUI(network, animated: false) {
                _ in
            }
        }
        
        func loginOldUser(token: String) {
            switch self.auth {
            case .none: break
            case .user:
                Auth.shared.user.register(with: token)
                let nav = UINavigationController.instantiateVC(.user, withId: "UserFindJobNavigationController")
                UIApplication.shared.windows.first?.rootViewController = nav
                
                registerDeviceRequest(auth: .user)
            case .jobber:
                Auth.shared.jobber.register(with: token)
                let tb = UITabBarController.instantiateVC(.jobber, withId: "JobberTabBarViewController")
                UIApplication.shared.windows.first?.rootViewController = tb
                
                registerDeviceRequest(auth: .jobber)
            }
            
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
                
        var region = Locale.preferredLanguages[0].components(separatedBy: "-").first ?? "en"
        
        if region != "en" { region = "fr" }

        let path = (auth == .user) ? "user":"jobber"
        let network = RestfulAPI<SendCurrentRegion,Generic<RCCheckOTP>>.init(path: "/\(path)/register/get_token")
            .with(method: .POST)
            .with(auth: .none)
            .with(body: SendCurrentRegion(region: region))
        
        handleRequestByUI(network, disable: [nextButton]) { (response) in
            if let token = response.data?.token {
                // oldUser
                loginOldUser(token: token)
            } else {
                // createUser
                registerForNewUser()
            }
        }
    }
    
    @IBAction func resendButtonTapped(_ sender: Any) {
        setupTimer()

        guard let phoneNumber = phoneNumber else { return }
        
        let sendOTP = SendOTP(phoneNumber: phoneNumber)
        let network = RestfulAPI<SendOTP,Generic<EMPTYMODEL>>.init(path: "/common/otp/send")
            .with(method: .POST)
            .with(body: sendOTP)

        handleRequestByUI(network) {
            _ in
        }
    }
}

extension VerificationViewController: DigitEntryViewDelegate {
    func digitsDidFinish(_ digitEntryView: DigitEntryView) {
        view.endEditing(true)
        nextButton.isOn = true
    }
    
    func digitsDidChange(_ digitEntryView: DigitEntryView) {
        func enable(_ condition: Bool) { nextButton.isOn = condition }
        
        digitEntryView.text.count != numberOfVerificationDigits ? enable(false):enable(true)
    }
}
