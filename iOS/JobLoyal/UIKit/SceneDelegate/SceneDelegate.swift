//
//  SceneDelegate.swift
//  JobLoyal
//
//  Created by Sina khanjani on 12/11/1399 AP.
// .

import UIKit
import RestfulAPI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        
        setCurrentLocaleRequest { [weak self] in
            // route to current vc
            self?.route(windowScene: windowScene)
            // open request tab for jobber if notification come's
            if let response = connectionOptions.notificationResponse {
                if Authentication.jobber.isLogin {
                    let info = response.notification.request.content.userInfo
                    if let method = info["method"] as? String {
                        if method == "NEW" {
                            if let tbc = self?.window?.rootViewController as? UITabBarController {
                                tbc.selectedIndex = 1
                            }
                        }
                    }
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        NotificationCenter.default.post(name: .sceneDidEnterForeground, object: nil)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

extension SceneDelegate {
    func setCurrentLocaleRequest(completion: @escaping () -> Void) {
        let auth = Auth.shared
        let currentLocale = Locale.preferredLanguages[0]
        // check if user is not register in app
        if !auth.user.isLogin && !auth.jobber.isLogin {
            completion()
            return
        }
        // check user change the current locale
        if (UserDefaults.standard.value(forKey: "currentLocale") as? String) == currentLocale {
            completion()
            return
        }
        // current region
        var region = currentLocale.components(separatedBy: "-").first ?? "en"
        // set france language for other region
        if region != "en" { region = "fr" }
        // set request for a jobber or user
        let sendCurrentRegion = SendCurrentRegion(region: region)
        let isUser = (auth.user.isLogin)
        let path = isUser ? "user":"jobber"
        var authentication: Authentication = isUser ? .user:.jobber
        // send request
        RestfulAPI<SendCurrentRegion,Generic<RCCheckOTP>>.init(path: "/\(path)/profile/edit_region")
            .with(method: .POST)
            .with(body: sendCurrentRegion)
            .with(auth: authentication)
            .sendURLSessionRequest { result in
                switch result {
                case .success(let response):
                    if let token = response.data?.token, response.success {
                        authentication.register(with: token)
                        UserDefaults.standard.setValue(currentLocale, forKey: "currentLocale")
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                            completion()
                        }
                    }
                case .failure(let err):
                    print(err)
                }
            }
    }
    
    func route(windowScene :UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        let auth = Auth.shared
        var authentication: Authentication = .none
        // if no one login
        if !auth.user.isLogin && !auth.jobber.isLogin {
            window.rootViewController = PageViewContentController.instantiateVC()
            authentication = .none
        }
        // if user is login
        if auth.user.isLogin {
            // route to user
            authentication = .user
            window.rootViewController = UINavigationController.instantiateVC(.user, withId: "UserFindJobNavigationController")
        }
        // if jobber is login
        if auth.jobber.isLogin {
            // route to jobber JobberTabBarViewController
            authentication = .jobber
            window.rootViewController = UITabBarController.instantiateVC(.jobber, withId: "JobberTabBarViewController")
        }
        // initialize window
        self.window = window
        window.makeKeyAndVisible()
        // check the last app version for user and jobber
        checkLastVersionRequest(auth: authentication, window: window)
        // register for push and local notification
    }
}

extension SceneDelegate {
    func checkLastVersionRequest(auth: Authentication, window: UIWindow) {
        guard auth != .none else { return }
        let isJobber = auth == .jobber ? true:false
        RestfulAPI<SendCheckLastVersionModel,Generic<RCCheckLastVersionModel>>.init(path: "/common/version")
            .with(body: SendCheckLastVersionModel(device_type: "ios", is_jobber_app: isJobber))
            .with(method: .POST)
            .sendURLSessionRequest { (result) in
                switch result {
                case .success(let response):
                    guard let data = response.data else { return }
                    guard let currentBuild = Int(UIApplication.appBuild) else { return } // build version of application
                    guard currentBuild < (data.versionCode ?? 0) else { return }
                    // this is the force upadate comming up
                    if (data.force ?? false) {
                        //// open force warningVC and stop user
                        let description = response.data?.dataDescription ?? "New update available".localized()
                        let alertContent = AlertContent(title: .update, subject: "Update Jobloyal".localized(), description: description.localized())
                        let versionVC = VersionContentViewController
                            .instantiateVC()
                            .alert(alertContent)
                        
                        versionVC.yesButtonTappedHandler = {
                            if let link = data.link, let url = URL(string: link) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        DispatchQueue.main.async {
                            window.rootViewController?.present(versionVC, animated: true)
                        }
                    } else {
                        guard let period = data.period, period != 0 else { return }
                        // save this to storage userDefaults.
                        var openAppCount = UserDefaults.standard.integer(forKey: "openAppCount")
                        // condition openAppCount
                        if ((openAppCount % period) == 0) {
                            //// open warning vc and show alert
                            let alertContent = AlertContent(title: .none, subject: "Update Jobloyal".localized(), description: data.dataDescription ?? "New update available، Update the application version to get the latest features and other things!".localized())
                            let alertVC = AlertContentViewController
                                .instantiateVC()
                                .alert(alertContent)
                            
                            DispatchQueue.main.async {
                                window.rootViewController?.present(alertVC.prepare(alertVC.interactor), animated: true)
                            }
                            // increse open application counter
                            openAppCount+=1
                            UserDefaults.standard.set(openAppCount, forKey: "openAppCount")
                        }
                    }
                case .failure(_): break
                }
            }
    }
}
