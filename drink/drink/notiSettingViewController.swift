//
//  notiSettingViewController.swift
//  drink
//
//  Created by user on 17/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth

class notiSettingViewController:UIViewController{
    @IBOutlet weak var label_messageBg: UILabel!
    @IBOutlet weak var label_callBg: UILabel!
    @IBOutlet weak var label_chatRoom: UILabel!
    @IBOutlet weak var label_event: UILabel!
    ///배경 라벨
    @IBOutlet weak var btn_message: UIButton!
    @IBOutlet weak var btn_call: UIButton!
    @IBOutlet weak var btn_chatRoom: UIButton!
    @IBOutlet weak var btn_event: UIButton!
    //버튼 선언
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var label_call: UILabel!
    @IBOutlet weak var label_chatroom: UILabel!
    @IBOutlet weak var label_Event: UILabel!
    
    var check:UIImage?
    var uncheck:UIImage?
    
    var pushSetting:String?
    
    let db = Database.database().reference()
    
    override func viewDidLoad(){
        
        if #available(iOS 13, *)
        {
              let app = UIApplication.shared
              let statusBarHeight: CGFloat = app.statusBarFrame.size.height
              
              let statusbarView = UIView()
              statusbarView.backgroundColor =  UIColor(red: 214.0/255, green: 214.0/255, blue: 214.0/255, alpha: 1.0)

              view.addSubview(statusbarView)
            
              statusbarView.translatesAutoresizingMaskIntoConstraints = false
              statusbarView.heightAnchor
                  .constraint(equalToConstant: statusBarHeight).isActive = true
              statusbarView.widthAnchor
                  .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
              statusbarView.topAnchor
                  .constraint(equalTo: view.topAnchor).isActive = true
              statusbarView.centerXAnchor
                  .constraint(equalTo: view.centerXAnchor).isActive = true
        }else{
            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            if statusBar!.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar!.backgroundColor = UIColor(red: 214.0/255, green: 214.0/255, blue: 214.0/255, alpha: 1.0)
                //상태바에 색을 입혀서 웹뷰의 컨텐츠가 상태바에 보이지 않도록함
            }
        }
        
        check = UIImage(named: "baseline_check_box_black_24pt")
        uncheck = UIImage(named: "baseline_check_box_outline_blank_black_24pt")
        
        /*if (UserDefaults.standard.value(forKey: "messagePush") != nil){
            let messagePush = UserDefaults.standard.value(forKey: "messagePush") as! Bool
            if (messagePush == true){
                btn_message.setImage(check, for: UIControl.State.normal)
            }else if (messagePush == false){
                btn_message.setImage(uncheck, for: UIControl.State.normal)
            }
        }*/
        
        defaultSetting(kind: "messagePush", btn: btn_message)
        defaultSetting(kind: "requestPush", btn: btn_call)
        defaultSetting(kind: "chatroomPush", btn: btn_chatRoom)
        defaultSetting(kind: "eventPush", btn: btn_event)
    }
    
    func defaultSetting(kind:String, btn:UIButton){
        if (UserDefaults.standard.value(forKey: kind) != nil){
            let push = UserDefaults.standard.value(forKey: kind) as! Bool
            if (push == true){
                btn.setImage(check, for: UIControl.State.normal)
            }else if (push == false){
                btn.setImage(uncheck, for: UIControl.State.normal)
            }
        }else{
            btn.setImage(check, for: UIControl.State.normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        drawShadow(settingLabel: label_message, bg: label_messageBg)
        drawShadow(settingLabel: label_call, bg: label_callBg)
        drawShadow(settingLabel: label_chatroom, bg: label_chatRoom)
        drawShadow(settingLabel: label_Event, bg: label_event)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.barStyle = .default
        let titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.tintColor = .darkGray

    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray, height: 1)
    }
    
    func drawShadow(settingLabel:UILabel, bg:UILabel){
        settingLabel.layer.cornerRadius = 10
        
        settingLabel.layer.masksToBounds = true
        
        //label_myLocation.layer.cornerRadius = 10
        let shadowPath = UIBezierPath(roundedRect: settingLabel.bounds, cornerRadius: 10)
        bg.layer.masksToBounds = false
        bg.layer.shadowRadius = 10.0
        bg.layer.shadowColor = UIColor.black.cgColor
        bg.layer.shadowOffset = CGSize(width: 1, height: 1)
        bg.layer.shadowOpacity = 0.2
        bg.layer.shadowPath = shadowPath.cgPath//그림자 넣기
    }
    
    @IBAction func messageTapped(_ sender: Any) {
        if (UserDefaults.standard.value(forKey: "messagePush") != nil){
            let push = UserDefaults.standard.value(forKey: "messagePush") as! Bool
            if (push == true){
                btn_message.setImage(uncheck, for: UIControl.State.normal)
                turnOff(kind: "flagMessage")
                UserDefaults.standard.set(false, forKey: "messagePush")
                UserDefaults.standard.synchronize()
            }else if (push == false){
                btn_message.setImage(check, for: UIControl.State.normal)
                turnOn(kind: "flagMessage")
                UserDefaults.standard.set(true, forKey: "messagePush")
                UserDefaults.standard.synchronize()
            }
        }else{
            btn_message.setImage(uncheck, for: UIControl.State.normal)
            turnOff(kind: "flagMessage")
            UserDefaults.standard.set(false, forKey: "messagePush")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func callTapped(_ sender: Any) {
        if (UserDefaults.standard.value(forKey: "requestPush") != nil){
            let push = UserDefaults.standard.value(forKey: "requestPush") as! Bool
            if (push == true){
                btn_call.setImage(uncheck, for: UIControl.State.normal)
                turnOff(kind: "flagPropose")
                UserDefaults.standard.set(false, forKey: "requestPush")
                UserDefaults.standard.synchronize()
            }else if (push == false){
                btn_call.setImage(check, for: UIControl.State.normal)
                turnOn(kind: "flagPropose")
                UserDefaults.standard.set(true, forKey: "requestPush")
                UserDefaults.standard.synchronize()
            }
        }else{
            btn_call.setImage(uncheck, for: UIControl.State.normal)
            turnOff(kind: "flagPropose")
            UserDefaults.standard.set(false, forKey: "requestPush")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func chatroomTapped(_ sender: Any) {
        if (UserDefaults.standard.value(forKey: "chatroomPush") != nil){
            let push = UserDefaults.standard.value(forKey: "chatroomPush") as! Bool
            if (push == true){
                btn_chatRoom.setImage(uncheck, for: UIControl.State.normal)
                turnOff(kind: "flagRecive")
                UserDefaults.standard.set(false, forKey: "chatroomPush")
                UserDefaults.standard.synchronize()
            }else if (push == false){
                btn_chatRoom.setImage(check, for: UIControl.State.normal)
                turnOn(kind: "flagRecive")
                UserDefaults.standard.set(true, forKey: "chatroomPush")
                UserDefaults.standard.synchronize()
            }
        }else{
            btn_chatRoom.setImage(uncheck, for: UIControl.State.normal)
            turnOff(kind: "flagRecive")
            UserDefaults.standard.set(false, forKey: "chatroomPush")
            UserDefaults.standard.synchronize()
        }
    }
    
    @IBAction func eventTapped(_ sender: Any) {
        if (UserDefaults.standard.value(forKey: "eventPush") != nil){
            let push = UserDefaults.standard.value(forKey: "eventPush") as! Bool
            if (push == true){
                btn_event.setImage(uncheck, for: UIControl.State.normal)
                UserDefaults.standard.set(false, forKey: "eventPush")
                UserDefaults.standard.synchronize()
            }else if (push == false){
                btn_event.setImage(check, for: UIControl.State.normal)
                UserDefaults.standard.set(true, forKey: "eventPush")
                UserDefaults.standard.synchronize()
            }
        }else{
            btn_event.setImage(uncheck, for: UIControl.State.normal)
            UserDefaults.standard.set(false, forKey: "eventPush")
            UserDefaults.standard.synchronize()
        }
    }
    
    func turnOn(kind:String){
        let uid = Auth.auth().currentUser?.uid
        self.db.child("users").child(uid!).child(kind).setValue(0)
    }
    
    func turnOff(kind:String){
        let uid = Auth.auth().currentUser?.uid
        self.db.child("users").child(uid!).child(kind).setValue(1)
    }
}
