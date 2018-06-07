//
//  AppDelegate.swift
//  swTest2
//
//  Created by Ghazalah on 1/23/18.
//  Copyright © 2018 Pratyush. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Fabric
import Crashlytics
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {    //, GIDSignInDelegate

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        let _ = RCValues.sharedInstance
        //Crashlytics.sharedInstance().crash()
        GIDSignIn.sharedInstance().clientID = "47447659942-ucm6brua5ooof9t3j30eo8lj6iu8ddki.apps.googleusercontent.com"
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
//    func application(application: UIApplication,
//                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
//        return GIDSignIn.sharedInstance().handleURL(url as URL,
//                                                    sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
//                                                    annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
//    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
//              withError error: Error!) {
//        if let error = error {
//            print("\(error.localizedDescription)")
//        } else {
//            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
//            // ...
//        }
//    }
//
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
//              withError error: Error!) {
//        // Perform any operations when the user disconnects from app here.
//        // ...
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        let alert = UIAlertController(title: "Barsys", message: "Turn Bluetooth off to conserve battery.", preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
//        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //Thread.sleep(forTimeInterval: 2.0)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }


}

