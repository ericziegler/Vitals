//
//  AppDelegate.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        applyApplicationAppearanceProperties()
//        var vitals = Vitals()
//        vitals.date = Date().dateByAddingDays(-1)
//        vitals.timeOfDay = .am
//        vitals.weight = 182
//        vitals.temperature = 96.8
//        vitals.systolic = 121
//        vitals.diastolic = 84
//        vitals.pulse = 78
//        VitalsLog.shared.add(vitals: vitals)
//        vitals = Vitals()
//        vitals.date = Date().dateByAddingDays(-1)
//        vitals.timeOfDay = .pm
//        vitals.weight = 184
//        vitals.temperature = 97.0
//        vitals.systolic = 130
//        vitals.diastolic = 93
//        vitals.pulse = 77
//        VitalsLog.shared.add(vitals: vitals)
//        vitals = Vitals()
//        vitals.date = Date()
//        vitals.timeOfDay = .am
//        vitals.weight = 184
//        vitals.temperature = 97.1
//        vitals.systolic = 133
//        vitals.diastolic = 90
//        vitals.pulse = 85
//        VitalsLog.shared.add(vitals: vitals)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

