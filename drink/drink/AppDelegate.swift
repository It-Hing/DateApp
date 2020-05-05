//
//  AppDelegate.swift
//  drink
//
//  Created by user on 01/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import UserNotifications
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //GMSServices.provideAPIKey("AIzaSyCU1YXfmAgNLY8k0GoGMLO0Xl5Llpa9f_Y")
        GMSServices.provideAPIKey("AIzaSyDrs0-fawTYee8tx0pCnl_58LEvtZ2q2BA")
        //GMSPlacesClient.provideAPIKey("AIzaSyAgjXE3atc-NL1n7l_VkTgNXvC752XHsBs")
    
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        }else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        //
        
        if #available(iOS 13.0, *){
            self.window?.overrideUserInterfaceStyle = .light
        }
        //다크모드를 지원하지 않음.
        
        //UserDefaults.standard.removeObject(forKey:"enrollProfile")
        
        /*if KeychainWrapper.standard.string(forKey: "enrollProfile") == nil{
            let firebaseAuth = Auth.auth()
            do {
                KeychainWrapper.standard.removeObject(forKey: "loginCheck")
                KeychainWrapper.standard.removeAllKeys()
                try firebaseAuth.signOut()
            }catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }*/
        //로그인, 30일 가입제한 풀기

        /*if KeychainWrapper.standard.bool(forKey: "loginCheck") != nil{
            let loginCheck = KeychainWrapper.standard.bool(forKey: "loginCheck")
            if loginCheck == false{
                print("푸시 걸러짐")
                return
            }
        }
        
        if (String(describing:userInfo["click_action"]!) == "p"){
            if(UserDefaults.standard.value(forKey: "requestPush") != nil){
                let push = UserDefaults.standard.value(forKey: "requestPush") as! Bool
                if (push == true){
                    
                }else{
                    return
                }
            }
        }else if(String(describing:userInfo["click_action"]!) == "r"){
            if(UserDefaults.standard.value(forKey: "chatroomPush") != nil){
                let push = UserDefaults.standard.value(forKey: "chatroomPush") as! Bool
                if (push == true){
                    
                }else{
                    return
                }
            }
        }else if(String(describing:userInfo["click_action"]!) == "m"){
            if(UserDefaults.standard.value(forKey: "messagePush") != nil){
                let push = UserDefaults.standard.value(forKey: "messagePush") as! Bool
                if (push == true){
                    
                }else{
                    return
                }
                
            }
        }*/
        
        UserDefaults.standard.set("1", forKey: "startPage")
        UserDefaults.standard.synchronize()
        ////////////////앱이 꺼진상태에서 푸시를 클릭해서 앱을 실행시켰을 때
        if let notification = launchOptions?[.remoteNotification] as? [String:AnyObject]{
            let aps = notification["aps"] as! [String:AnyObject]
            print(aps)
            //let db = Database.database().reference()
            //db.child("notePad").setValue(aps["category"])
            if (String(describing:aps["category"]!) == "p"){
                UserDefaults.standard.set("3", forKey: "startPage")
                UserDefaults.standard.synchronize()
            }else if(String(describing:aps["category"]!) == "r"){
                UserDefaults.standard.set("2", forKey: "startPage")
                UserDefaults.standard.synchronize()
            }else if(String(describing:aps["category"]!) == "m"){
                UserDefaults.standard.set("2", forKey: "startPage")
                UserDefaults.standard.synchronize()
            }
            print("푸시를 클릭해서 앱이 켜짐")
        }else{
            print("푸시를 클릭해도 해당 구문이 실행되지 않음")
        }
        //////////////////
        
        if KeychainWrapper.standard.bool(forKey: "loginCheck") != nil{
            print("loginCheck있음")
            let loginCheck = KeychainWrapper.standard.bool(forKey: "loginCheck")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if loginCheck == false{
                //시작하는 뷰를 지정해주기
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "tempLoginController") as! tempLoginController
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }else{
                //let initialViewController = storyboard.instantiateViewController(withIdentifier: "firstPageController")
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabBarNavigationBar")
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
            return true
        }else{
            //오류발생 지점
            print("loginCheck없음")
            print("uid가 nil")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "firstPageController")
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            return true
            //토큰 값 바꿔주는 메소드 필요할수도 있음
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if (/*key != "myLocation" && */key != "sex" && key != "latitude" && key != "longitude" && key != "mySex"){
                UserDefaults.standard.removeObject(forKey: key.description)
                UserDefaults.standard.synchronize()
                print("Userdefault 설정 초기화")
            }else{
                print(key)
            }
        }
        
        /*let db = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        db.child("users").child(uid!).child("sex").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
            
            let sex = String(describing: datasnapshot.value!)
            if (sex == "남자"){
                db.child("man_location").child(uid!).removeValue()
            }else{
                db.child("woman_location").child(uid!).removeValue()
            }
            
            UserDefaults.standard.set(false, forKey: "myLocation")
            UserDefaults.standard.synchronize()
            
        })*/
    }

    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
        print("여기")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        // Print full message.
        print(userInfo)
        print("요기")
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    //메세지 보냈을 때 여기서 받음
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        print("11111111111")
        // Change this to your preferred presentation option
        
        print(userInfo["click_action"]!)
        
        if KeychainWrapper.standard.bool(forKey: "loginCheck") != nil{
            let loginCheck = KeychainWrapper.standard.bool(forKey: "loginCheck")
            if loginCheck == false{
                print("푸시 걸러짐")
                return
            }
        }
        
        /*let auth = UserDefaults.standard.value(forKey: "myLocation")
        
        if (auth == nil){
            return
        }else if(auth as! Bool == false){
            return
        }*/
        
        //loginCheck가 false면 로그아웃되어있는 상태이므로 푸시를 받지 않게한다.
        //loginCheck가 값이 없으면 한번도 로그아웃한적 없는상태
        
        /*"messagePush", btn: btn_message)
        defaultSetting(kind: "requestPush", btn: btn_call)
        defaultSetting(kind: "chatroomPush", btn: btn_chatRoom)
        defaultSetting(kind: "eventPush*/
        
        if (String(describing:userInfo["click_action"]!) == "p"){
            if(UserDefaults.standard.value(forKey: "requestPush") != nil){
                let push = UserDefaults.standard.value(forKey: "requestPush") as! Bool
                if (push == true){
                    
                }else{
                    return
                }
            }
        }else if(String(describing:userInfo["click_action"]!) == "r"){
            if(UserDefaults.standard.value(forKey: "chatroomPush") != nil){
                let push = UserDefaults.standard.value(forKey: "chatroomPush") as! Bool
                if (push == true){
                    
                }else{
                    return
                }
            }
        }else if(String(describing:userInfo["click_action"]!) == "m"){
            if(UserDefaults.standard.value(forKey: "messagePush") != nil){
                let push = UserDefaults.standard.value(forKey: "messagePush") as! Bool
                if (push == true){
                    
                }else{
                    return
                }
            }
        }

        //채팅방에서 서로대화중일 때 푸시를 받지 않게함.
        if (UserDefaults.standard.value(forKey: userInfo["title"] as! String) != nil){
            let name = UserDefaults.standard.value(forKey: userInfo["title"] as! String) as! Bool
            //채팅방밖에 있는 경우 푸시를 받음
            if (name == false){
                print("현재 채팅방 밖에 있어서 푸시받지 않음")
                completionHandler([.alert, .badge, .sound])
            }else{
                //현재 채팅방에 있는경우 상대의 푸시를 받지않음
                print("현재 채팅방에 있어서 푸시받지 않음")
                completionHandler([])
            }
        }else{
            completionHandler([.alert, .badge, .sound])
            print("채팅로컬디비없음")
        }
    }
    
    //백그라운드 상태일때는 여기로 푸시옴 //포그라운드에서 클릭했을 때도 여기로 옴
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        print("222222222222")
        
        /*let auth = UserDefaults.standard.value(forKey: "myLocation")
        
        if (auth == nil){
            return
        }else if(auth as! Bool == false){
            return
        }*/
        
        ////////////////앱이 꺼진상태에서 푸시를 클릭해서 앱을 실행시켰을 때
        UserDefaults.standard.set("1", forKey: "startPage")
        UserDefaults.standard.synchronize()
        if (String(describing:userInfo["click_action"]!) == "p"){
            UserDefaults.standard.set("3", forKey: "startPage")
            UserDefaults.standard.synchronize()
        }else if(String(describing:userInfo["click_action"]!) == "r"){
            UserDefaults.standard.set("2", forKey: "startPage")
            UserDefaults.standard.synchronize()
        }else if(String(describing:userInfo["click_action"]!) == "m"){
            UserDefaults.standard.set("2", forKey: "startPage")
            UserDefaults.standard.synchronize()
        }
        //////////////////
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}
