//
//  NotificationNameExtention.swift
//  Master
//
//  Created by Sina khanjani on 11/26/1399 AP.
//

import Foundation

extension Notification.Name {
    static let jobberJobStatus = Notification.Name("jobber.jobStatus")
    static let userJobStatus = Notification.Name("user.jobStatus")
    
    static let reachabilityStatusChangedNotification =  NSNotification.Name(rawValue: "ReachabilityStatusChangedNotification")
    
    static let userStatusChanged =  NSNotification.Name(rawValue: "userStatusChangedNotification")
    static let jobberStatusChanged =  NSNotification.Name(rawValue: "jobberStatusChangedNotification")
    
    static let userProfileChanged =  NSNotification.Name(rawValue: "userProfileChanged")
    static let jobberProfileChanged =  NSNotification.Name(rawValue: "userProfileChanged")
    
    static let sceneDidEnterForeground =  NSNotification.Name(rawValue: "sceneDidEnterForeground")
    
    static let cnlReceiveRemoteNotification =  NSNotification.Name(rawValue: "cnlReceiveRemoteNotification")
    static let newReceiveRemoteNotification =  NSNotification.Name(rawValue: "newReceiveRemoteNotification")
}
