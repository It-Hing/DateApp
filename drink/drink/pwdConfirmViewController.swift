//
//  pwdConfirmViewController.swift
//  drink
//
//  Created by user on 10/11/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftKeychainWrapper

class pwdConfirmViewController:UIViewController{
    @IBOutlet weak var label_alertTitle: UILabel!
    @IBOutlet weak var pwdConfirmField: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var label_alertContent: UILabel!
    
    var alertContent:String?
    var alertTitle:String?
    var okAction:(() -> ())? = nil
    var loginState:Bool?
    let db = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label_alertTitle.text = alertTitle
        label_alertContent.text = alertContent
        label_alertContent.textAlignment = NSTextAlignment.center

        popUpView.layer.cornerRadius = 5.0
        popUpView.layer.masksToBounds = true
        
        label_alertContent.numberOfLines = 0
        
        backView.isUserInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        backView.addGestureRecognizer(tap)
        popUpView.isUserInteractionEnabled = true
        popUpView.addGestureRecognizer(tap)
    }
    
    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        //if (loginState == true){
            let email = KeychainWrapper.standard.string(forKey: "email")
            reauthenticateUserWith(email: email!, password: pwdConfirmField.text!)
        //}else{
            
        //}
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func reauthenticateUserWith(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("재인증 성공")
                if (self.loginState == false){
                    //심플로그인에서 로그인하면 계정값을 키체인에 새로써줌
                    KeychainWrapper.standard.set(email, forKey: "email")
                    KeychainWrapper.standard.set(password, forKey: "pwd")
                }
                
                ////////디바이스 인포에 정보가 있으면 비밀번호 변경 해주기
                let email = Auth.auth().currentUser?.email
                self.db.child("deviceinfo").queryOrdered(byChild: "/email").queryEqual(toValue: email).observeSingleEvent(of: DataEventType.value,with: {(DataSnapshot) in
                    if DataSnapshot.exists(){
                        let data = DataSnapshot.value as! [String:AnyObject]
                        
                        for item in data{
                            print(item.key)
                            self.db.child("deviceinfo").child(item.key).child("password").setValue(password)
                        }
                    }
                })
                /////////
                
                self.okAction!()
                self.dismiss(animated: true, completion: nil)
            }else {
                //handle error
                if (self.loginState == true){
                    self.invalidPassword()
                }else{
                    self.resetPassword()
                }
                //self.dismiss(animated: true, completion: self.invalidPassword)
            }
        }
    }
    
    func resetPassword(){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "emailConfirmViewController") as! emailConfirmViewController
        popupVC.alertTitle = "비밀번호 재설정"
        popupVC.alertContent = "비밀번호 재설정을 위한 이메일 입력"
        
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func invalidPassword(){
        
        /*let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "simpleAlertViewController") as! simpleAlertViewController
        popupVC.alertTitle = "인증오류"
        popupVC.alertContent = "암호가 틀렸습니다."
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)*/
        ToastViewController.show(message: "비밀번호가 틀렸습니다.", controller: self)
        
        /*let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "pwdConfirmViewController") as! pwdConfirmViewController
        popupVC.alertTitle = "이메일 입력"
        popupVC.alertContent = "비밀번호가 기억나지 않는다면\n비밀번호 재설정을 위한 메일을 적어주세요."
        popupVC.contentKind = "email"
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)*/
    }
}
