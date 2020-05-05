//
//  loginPageController.swift
//  drink
//
//  Created by user on 02/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import SwiftKeychainWrapper

class loginPageController: UIViewController{

    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var status: UILabel!
    //let db = Database.database().reference().child("users")
    
    @IBOutlet weak var label_email: UILabel!
    
    @IBOutlet weak var label_pwd: UILabel!
    let db = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        }
        
        label_email.layer.borderWidth = 0.5
        label_email.layer.borderColor = UIColor.lightGray.cgColor
        label_pwd.layer.borderWidth = 0.5
        label_pwd.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    //네비게이션바없이 화면전환할때 viewdidLoad에서 전환을 시도하면 오류가 생긴다.
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser{
            idField.placeholder = "이미 로그인 된 상태입니다."
            pwdField.placeholder = "이미 로그인 된 상태입니다."
            //self.moveToNext()
            let uid = Auth.auth().currentUser?.uid
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instance ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
            Database.database().reference().child("users").child(uid!).updateChildValues(["pushToken":result.token])
                    KeychainWrapper.standard.set(true, forKey: "loginCheck")
                    //로그인 되어 있다고 표시
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pwdResetTapped(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "emailConfirmViewController") as! emailConfirmViewController
        popupVC.alertTitle = "이메일 입력"
        popupVC.alertContent = "비밀번호 재설정을 위한 이메일 입력"
        
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        loadingVC.show()
        let email = idField.text
        let password = pwdField.text
        Auth.auth().signIn(withEmail: email!, password: password! ){(user,Error) in
            if Error != nil{
                loadingVC.hide()
                let err = AuthErrorCode(rawValue: Error!._code)
                if (err?.rawValue == 17009){
                    ToastViewController.show(message: "비밀번호가 유효하지 않습니다.", controller: self)
                }else if (err?.rawValue == 17011){
                    ToastViewController.show(message: "이메일이 유효하지 않습니다.", controller: self)
                }else{
                    ToastViewController.show(message: "로그인에 실패하였습니다.", controller: self)
                }
                return
            }
            else{
                let uid = Auth.auth().currentUser?.uid
                InstanceID.instanceID().instanceID { (result, error) in
                    if let error = error {
                        print("Error fetching remote instance ID: \(error)")
                    } else if let result = result {
                        print("Remote instance ID token: \(result.token)")
                        Database.database().reference().child("users").child(uid!).child("pushToken").setValue(result.token)
                        Database.database().reference().child("users").child(uid!).child("platform").setValue("ios")
                        Database.database().reference().child("users").child(uid!).updateChildValues([
                            "flagMessage" : 0,
                            "flagPropose" : 0,
                            "flagRecive" : 0
                            ])

                        KeychainWrapper.standard.set(email!, forKey: "email")
                        KeychainWrapper.standard.set(password!, forKey: "pwd")
                        KeychainWrapper.standard.set(true, forKey: "loginCheck")
                    }
                    ///////////디바이스 인포에 정보가 있으면 비밀번호 변경 해주기
                    let email = Auth.auth().currentUser?.email
                    self.db.child("deviceinfo").queryOrdered(byChild: "/email").queryEqual(toValue: email).observeSingleEvent(of: DataEventType.value,with: {(DataSnapshot) in
                        if DataSnapshot.exists(){
                            let data = DataSnapshot.value as! [String:AnyObject]
                            
                            for item in data{
                                print(item.key)
                                self.db.child("deviceinfo").child(item.key).child("password").setValue(self.pwdField.text)
                            }
                        }
                    })
                    ////////////
                    self.moveToNext()
                }
            }
        }
    }
    
    func moveToNext(){
        /*let chatViewController = storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! chatViewController
        self.navigationController?.pushViewController(chatViewController, animated: true)
        let chatRoomListController = storyboard?.instantiateViewController(withIdentifier: "chatRoomListController") as! chatRoomListController
        self.navigationController?.pushViewController(chatRoomListController, animated: true)*/
        /*let mapController = storyboard?.instantiateViewController(withIdentifier: "mapController") as! mapController*/
        
        //self.dismiss(animated: false, completion: nil)
        loadingVC.hide()
        if UserDefaults.standard.value(forKey: "sex") != nil{
            let sex = UserDefaults.standard.value(forKey: "sex") as! String
            UserDefaults.standard.set(sex, forKey:"sex")
            UserDefaults.standard.synchronize()
        }else{
            UserDefaults.standard.set("전체", forKey:"sex")
            UserDefaults.standard.synchronize()
        }

        if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarNavigationBar"){
            //tabBarController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            tabBarController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            tabBarController.modalPresentationStyle = .fullScreen
            //tabBarController.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
            //tabBarController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
            self.present(tabBarController, animated: true, completion: nil)
        }

        //self.navigationController?.pushViewController(tabBarController, animated: true)
    }
}
